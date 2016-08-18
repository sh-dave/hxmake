package hxmake.haxelib;

import hxmake.cli.FileUtil;
import hxmake.cli.CL;
import haxe.zip.Writer;
import sys.io.File;
import haxe.io.Bytes;
import haxe.zip.Entry;
import haxe.io.Path;
import sys.FileSystem;

class HaxelibPackageTask extends Task {

    public function new() {
        description = "Zip haxe library package";
    }

    override public function run() {
        var ext:Null<HaxelibExt> = module.get("haxelib", HaxelibExt);

        if(ext != null) {
            CL.workingDir.with(module.path, function() {
                packageFiles(ext);
            });
        }
    }

    function packageFiles(ext:HaxelibExt) {
        var files = FileUtil.getFilesRecursiveFromArray(ext.pack.includes, ext.pack.filters);
        var zipEntries = getZipEntries(files);

        var zip = File.write(module.name + ".zip", true);
        var writer:Writer = new Writer(zip);
        writer.write(zipEntries);
        zip.close();
    }

    public static function getZipEntries(files:Array<String>):List<Entry> {
        var entries:List<Entry> = new List();
        var date = Date.now();
        for (file in files) {
            var stat = FileSystem.stat(file);
            var isDir = FileSystem.isDirectory(file);
            var bytes:Bytes = isDir ? null: File.getBytes(file);
            var name:String = isDir ? (Path.directory(file) + "/") : file;

            var entry:Entry = {
                fileTime: date,
                fileName: name,
                fileSize: stat.size,
                data: bytes,
                dataSize: bytes != null ? bytes.length : 0,
                compressed: false,
                crc32: 0,
                extraFields: new List()
            }

            Sys.println("Added " + entry.fileName);
            entries.add(entry);
        }

        return entries;
    }

}