HTTP API
========
Homegirl is able to mount websites as drives, provided the website is at least somewhat crawler friendly. Any static webserver with directory listings enabled can be mounted as a read-only drive.

Any HTTP request from Homegirl will be provided with a `User-Agent` header with name and version of the console, and a `Referer` header referring to the program causing the request, if that program is from a webserver.

Getting directory contents
--------------------------
Whenever Homegirl accesses a HTML resource on a webserver, the contents will be scanned for any tags with either a `src` or `href` attribute, resolve the references and mark them as existing files in the cache. So whenever `fs.list` is called, it returns a modified list of the entries in cache.

Reading files
-------------
Reading a file from a webserver is just a simple `GET` request. Homegirl will then cache the result, even errors, for at least 10 minutes.

Writing files
-------------
When Homegirl tries to write a file to a webserver, a `PUT` request is issued to the desired URL of the file with the file contents in the request body. If the server replies with an error (HTTP status 400 or above), Homegirl will try and (re)fetch the original file from the server, if it exists.

Deleting files and directories
------------------------------
To delete files or directories, a `DELETE` request is issued to the URL that should be deleted. An error results in Homegirl trying to refetch the file.

Creating directories
--------------------
Homegirl expects webservers, that support the `PUT` method, to recursively create any directories needed to write to the desired path. So to create a directory, Homegirl will simply write an empty file inside the directory and then delete it, so that only an empty directory remains. (Provided the directory wasn't already there.)

Renaming/moving files and directories
-------------------------------------
To rename files and directories, a `PATCH` request is issued to the URL that needs to be renamed, with a `Location` header that provides the new desired path. An error will result in trying to refetch both the old and new path.

