import hashlib
import io
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'install.sh'

@unittest.skipIf(os.name == 'nt', 'POSIX installer tests run on macOS and Linux')
class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='xailon-installer-test-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.mock = self.root / 'mock'; self.mock.mkdir()
        self.downloads = self.root / 'downloads'; self.downloads.mkdir()
        self.prefix = self.root / 'install space'
        self.home = self.root / 'home'; self.home.mkdir()
        self.env = dict(os.environ, HOME=str(self.home), PATH=str(self.mock)+os.pathsep+os.environ['PATH'])
        self.platform('Darwin', 'arm64')
        self.write_tool('curl', f'''#!{sys.executable}
import pathlib,sys,urllib.parse
path=urllib.parse.urlsplit(sys.argv[-1]).path.split('/')
source=pathlib.Path({str(self.downloads)!r})/path[-2]/path[-1]
if not source.is_file(): sys.exit(22)
sys.stdout.buffer.write(source.read_bytes())
''')
    def write_tool(self, name, content):
        tool=self.mock/name; tool.write_text(content); tool.chmod(0o755)
    def platform(self, system, arch):
        self.write_tool('uname', f'#!/bin/sh\ncase "$1" in -s) echo {system};; -m) echo {arch};; esac\n')
    def archive(self, version, broken=False, symlink=False):
        folder=self.downloads/version; folder.mkdir()
        filename='xailon-aarch64-apple-darwin.tar.bz2'
        archive=folder/filename
        with tarfile.open(archive,'w:bz2') as output:
            for name in ('xailon','xailond','LICENSE','NOTICE'):
                entry=tarfile.TarInfo(name); entry.mode=0o755 if name.startswith('xailon') else 0o644
                if symlink and name=='xailon':
                    entry.type=tarfile.SYMTYPE; entry.linkname='/bin/sh'; output.addfile(entry); continue
                content=(f'#!/bin/sh\nprintf "xailon {version[1:]}\\n"\n' if name.startswith('xailon') else 'License fixture\n').encode()
                entry.size=len(content); output.addfile(entry,io.BytesIO(content))
        digest='0'*64 if broken else hashlib.sha256(archive.read_bytes()).hexdigest()
        (folder/(filename+'.sha256')).write_text(f'{digest}  {filename}\n')
    def run_script(self, *args):
        return subprocess.run(['sh',str(SCRIPT),*args,'--prefix',str(self.prefix)],env=self.env,text=True,capture_output=True,timeout=20)
    def test_detects_all_unix_targets_without_changes(self):
        for system,arch,target in [('Darwin','arm64','aarch64-apple-darwin'),('Darwin','x86_64','x86_64-apple-darwin'),('Linux','x86_64','x86_64-unknown-linux-gnu'),('Linux','aarch64','aarch64-unknown-linux-gnu')]:
            self.platform(system,arch)
            self.write_tool('sysctl','#!/bin/sh\necho 0\n')
            result=self.run_script('--version','v0.2.13','--dry-run')
            self.assertEqual(result.returncode,0,result.stderr); self.assertIn(target,result.stdout)
            self.assertFalse(self.prefix.exists())
    def test_install_then_update_and_repeat(self):
        self.archive('v0.2.13'); self.archive('v0.2.14')
        for action,version in [('install','v0.2.13'),('update','v0.2.14'),('update','v0.2.14')]:
            result=self.run_script(action,'--version',version)
            self.assertEqual(result.returncode,0,result.stdout+result.stderr)
            binary=self.prefix/'bin/xailon'
            self.assertTrue(binary.is_symlink())
            self.assertEqual(subprocess.check_output([str(binary)],text=True).strip(),f'xailon {version[1:]}')
            self.assertTrue((self.prefix/'bin/xailond').exists())
    def test_bad_checksum_preserves_installed_version(self):
        self.archive('v0.2.13'); self.archive('v0.2.14',broken=True)
        self.assertEqual(self.run_script('--version','v0.2.13').returncode,0)
        result=self.run_script('update','--version','v0.2.14')
        self.assertNotEqual(result.returncode,0); self.assertIn('Checksum mismatch',result.stderr)
        self.assertEqual(subprocess.check_output([str(self.prefix/'bin/xailon')],text=True).strip(),'xailon 0.2.13')
    def test_rejects_executable_symlink(self):
        self.archive('v0.2.13',symlink=True)
        result=self.run_script('--version','v0.2.13')
        self.assertNotEqual(result.returncode,0); self.assertIn('regular xailon',result.stderr)
        self.assertFalse((self.prefix/'bin/xailon').exists())
    def test_existing_directory_is_preserved(self):
        self.archive('v0.2.13')
        existing=self.prefix/'bin/xailon'; existing.mkdir(parents=True)
        sentinel=existing/'keep.txt'; sentinel.write_text('keep')
        result=self.run_script('--version','v0.2.13')
        self.assertNotEqual(result.returncode,0); self.assertIn('Cannot replace a directory',result.stderr)
        self.assertEqual(sentinel.read_text(),'keep')
        self.assertEqual(len(list(existing.iterdir())),1)
    def test_unavailable_release_makes_no_install(self):
        result=self.run_script('--version','v0.2.99')
        self.assertNotEqual(result.returncode,0); self.assertIn('Download failed',result.stderr)
        self.assertFalse((self.prefix/'bin/xailon').exists())
    def test_rejects_unsupported_desktop_and_bad_version(self):
        self.platform('Linux','aarch64')
        result=self.run_script('--version','v0.2.13','--component','all','--dry-run')
        self.assertNotEqual(result.returncode,0); self.assertIn('not available',result.stderr)
        result=self.run_script('--version','v1/../../bad','--dry-run')
        self.assertNotEqual(result.returncode,0); self.assertIn('Invalid release version',result.stderr)

if __name__=='__main__': unittest.main()
