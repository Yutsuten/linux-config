from typing import Any
from unittest import TestCase, main, mock

from ffmeta import main as ffmeta


class TestSetMetadata(TestCase):

    @mock.patch('builtins.print')
    @mock.patch('ffmeta.shutil')
    @mock.patch('ffmeta.subprocess')
    def test_add_global_metadata(self, subprocess: Any, shutil: Any, bprint: Any) -> None:
        ffmeta(['title=GlobalTitle', 'music.mp3'])
        ffmpeg_call = subprocess.run.call_args_list[0].args
        self.assertEqual(
            ffmpeg_call,
            (['ffmpeg', '-loglevel', 'warning', '-i', 'music.mp3', '-codec', 'copy',
              '-metadata:g', 'title=GlobalTitle', '-y', 'new_music.mp3'],),
        )
        shutil.move.assert_called()
        self.assertEqual(bprint.call_count, 4)

    @mock.patch('builtins.print')
    @mock.patch('ffmeta.shutil')
    @mock.patch('ffmeta.subprocess')
    def test_add_stream_metadata(self, subprocess: Any, shutil: Any, bprint: Any) -> None:
        ffmeta(['0', 'title=Stream0Title', 'music.mp3'])
        ffmpeg_call = subprocess.run.call_args_list[0].args
        self.assertEqual(
            ffmpeg_call,
            (['ffmpeg', '-loglevel', 'warning', '-i', 'music.mp3', '-codec', 'copy',
             '-metadata:s:0', 'title=Stream0Title', '-y', 'new_music.mp3'],),
        )
        shutil.move.assert_called()
        self.assertEqual(bprint.call_count, 4)


class TestClearMetadata(TestCase):

    @mock.patch('builtins.print')
    @mock.patch('ffmeta.shutil')
    @mock.patch('ffmeta.subprocess')
    def test_clear_metadata(self, subprocess: Any, shutil: Any, bprint: Any) -> None:
        ffmeta(['-c', 'music.mp3'])
        ffmpeg_call = subprocess.run.call_args_list[0].args
        self.assertEqual(
            ffmpeg_call,
            (['ffmpeg', '-loglevel', 'warning', '-i', 'music.mp3', '-codec', 'copy',
             '-map_metadata', '-1', '-map_metadata:s', '-1', '-y', 'new_music.mp3'],),
        )
        shutil.move.assert_called()
        self.assertEqual(bprint.call_count, 4)

class TestCover(TestCase):

    @mock.patch('builtins.print')
    @mock.patch('ffmeta.shutil')
    @mock.patch('ffmeta.subprocess')
    def test_add_cover_mp3(self, subprocess: Any, shutil: Any, bprint: Any) -> None:
        ffmeta(['-C', 'Cover.jpg', 'music.mp3'])
        ffmpeg_call = subprocess.run.call_args_list[0].args
        self.assertEqual(
            ffmpeg_call,
            (['ffmpeg', '-loglevel', 'warning', '-i', 'music.mp3', '-i', 'Cover.jpg', '-metadata:s:1',
              'comment=Cover (front)', '-codec', 'copy', '-map', '0', '-map', '1', '-y', 'new_music.mp3'],),
        )
        shutil.move.assert_called()
        self.assertEqual(bprint.call_count, 4)

    @mock.patch('builtins.print')
    @mock.patch('ffmeta.shutil')
    @mock.patch('ffmeta.subprocess')
    def test_add_cover_opus(self, subprocess: Any, shutil: Any, bprint: Any) -> None:
        ffmeta(['-C', 'Cover.jpg', 'music.opus'])
        ffmpeg_call = subprocess.run.call_args_list[0].args
        self.assertEqual(
            ffmpeg_call,
            (['ffmpeg', '-loglevel', 'warning', '-i', 'music.opus', '-i', 'Cover.jpg', '-metadata:s:1',
              'comment=Cover (front)', '-acodec', 'copy', '-q:v', '10', '-map', '0', '-map', '1',
              '-y', 'music.ogg'],),
        )
        shutil.move.assert_not_called()
        self.assertEqual(bprint.call_count, 4)


class TestQuiet(TestCase):

    @mock.patch('builtins.print')
    @mock.patch('ffmeta.shutil')
    @mock.patch('ffmeta.subprocess')
    def test_quiet(self, subprocess: Any, shutil: Any, bprint: Any) -> None:
        ffmeta(['-q', 'title=GlobalTitle', 'music.mp3'])
        self.assertEqual(subprocess.run.call_count, 1)
        shutil.move.assert_called()
        bprint.assert_not_called()

    @mock.patch('builtins.print')
    @mock.patch('ffmeta.shutil')
    @mock.patch('ffmeta.subprocess')
    def test_not_quiet(self, subprocess: Any, shutil: Any, bprint: Any) -> None:
        ffmeta(['title=GlobalTitle', 'music.mp3'])
        self.assertEqual(subprocess.run.call_count, 3)
        shutil.move.assert_called()
        bprint.assert_called()

class TestDelete(TestCase):

    @mock.patch('builtins.print')
    @mock.patch('ffmeta.Path')
    @mock.patch('ffmeta.shutil')
    @mock.patch('ffmeta.subprocess')
    def test_delete(self, subprocess: Any, shutil: Any, path: Any, bprint: Any) -> None:
        ffmeta(['-x', 'title=GlobalTitle', 'music.mp3'])
        self.assertEqual(subprocess.run.call_count, 3)
        path().unlink.assert_called()
        shutil.move.assert_not_called()
        bprint.assert_called()

if __name__ == '__main__':
    main()
