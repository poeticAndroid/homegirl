module network;

import std.file;
import std.path;
import std.conv;
import std.uri;
import std.algorithm;
import std.datetime;
import std.net.curl;
import html;
import machine;

/**
  Networking system
*/
class Network
{
  string cacheDir; /// path to cache folder

  /**
    create network
  */
  this(string cacheDir)
  {
    this.cacheDir = buildNormalizedPath(cacheDir) ~ "/";
    if (!exists(this.cacheDir))
      mkdirRecurse(this.cacheDir);
    this.res = new Response();
    this.httpReq = HTTP();
    this.httpReq.setCookieJar(this.cacheDir ~ "cookiejar.txt");
    this.httpReq.onSend = delegate size_t(void[] data) {
      auto m = cast(void[]) upload;
      size_t length = m.length > data.length ? data.length : m.length;
      if (length == 0)
        return 0;
      data[0 .. length] = m[0 .. length];
      upload = upload[length .. $];
      return length;
    };
    this.httpReq.onReceiveStatusLine = (HTTP.StatusLine line) {
      this.res.code = line.code;
      this.res.headers.clear();
      this.res.data.length = 0;
    };
    this.httpReq.onReceiveHeader = (in char[] key, in char[] value) {
      this.res.headers[key] = to!string(value);
      if (key == "location")
        this.url = this.rel(this.url, to!string(value));
    };
    this.httpReq.onReceive = (ubyte[] data) {
      this.res.data ~= data;
      return data.length;
    };
    this.httpReq.setUserAgent("Homegirl " ~ VERSION);
    this.httpReq.dataTimeout = dur!"seconds"(10);
    this.httpReq.operationTimeout = dur!"seconds"(60);
    // this.httpReq.maxRedirects = 0;
    // this.httpReq.verbose = true;
  }

  void shutdown()
  {
    this.httpReq.clearSessionCookies();
    this.httpReq.flushCookieJar();
    this.httpReq.shutdown();
  }

  bool isUrl(string url)
  {
    if (url && url.length < 8)
      return false;
    if (url[0 .. 7] == "http://")
      return true;
    // if (url[0 .. 8] == "https://")
    //   return true;
    return false;
  }

  string actualFile(string url)
  {
    url = onlyPath(url);
    auto segs = pathSplitter(buildNormalizedPath(url));
    string filename = this.cacheDir;
    foreach (string seg; segs)
    {
      filename ~= encodeComponent(decodeComponent(seg)) ~ ".~dir/";
    }
    filename = filename[0 .. $ - 6] ~ ".~file";
    return filename;
  }

  string get(string url)
  {
    SysTime accessTime, modificationTime, now;
    url = onlyPath(url);
    string filename = this.actualFile(url);
    bool getit = true;
    if (exists(filename) && getSize(filename))
    {
      getTimes(filename, accessTime, modificationTime);
      now = Clock.currTime();
      const age = now.toUnixTime() - accessTime.toUnixTime();
      getit = age > 600;
    }
    if (getit)
    {
      this.exec(HTTP.Method.get, url);
      url = this.url;
      if (res.code < 300)
      {
        if (!exists(dirName(filename)))
          mkdirRecurse(dirName(filename));
        std.file.write(filename, res.data);
        this.httpReq.flushCookieJar();
        try
        {
          getTimes(filename, accessTime, modificationTime);
          modificationTime = parseRFC822DateTime(res.headers.get("last-modified", ""));
          setTimes(filename, accessTime, modificationTime);
        }
        catch (Exception err)
        {
        }
        try
        {
          this.crawl(url);
        }
        catch (Exception err)
        {
        }
      }
      else
      {
        if (exists(filename))
          remove(filename);
        string dirname = filename[0 .. $ - 6] ~ ".~dir";
        if (exists(dirname))
          rmdirRecurse(dirname);
      }
    }
    return filename;
  }

  bool sync(string url, string rename = null)
  {
    url = onlyPath(url);
    string filename = this.actualFile(url);
    string dirname = filename[0 .. $ - 6] ~ ".~dir";
    if (rename)
    {
      if (this.isUrl(rename))
      {
        rename = rename[8 .. $];
        rename = rename[countUntil(rename, "/") .. $];
      }
      httpReq.method = HTTP.Method.patch;
      httpReq.url = url;
      this.url = url;
      httpReq.clearRequestHeaders();
      httpReq.addRequestHeader("Location", rename);
      httpReq.perform();
      if (res.code >= 300)
      {
        this.get(url);
        rename = this.rel(url, rename);
        remove(this.actualFile(rename));
        this.get(rename);
        return false;
      }
      return true;
    }
    else if (exists(dirname))
    {
      if (url[$ - 1 .. $] != "/")
        url ~= "/";
      this.exec(HTTP.Method.put, url ~ "~empty", cast(ubyte[]) "delete me!",
          "application/octet-stream");
      uint code = res.code;
      this.exec(HTTP.Method.del, url ~ "~empty");
      if (code >= 300)
      {
        this.get(url);
        return false;
      }
      return true;
    }
    else if (exists(filename))
    {
      this.exec(HTTP.Method.put, url, cast(ubyte[]) std.file.read(filename),
          "application/octet-stream");
      if (res.code >= 300)
      {
        remove(filename);
        this.get(url);
        return false;
      }
      return true;
    }
    else
    {
      this.exec(HTTP.Method.del, url);
      if (res.code >= 300)
      {
        this.get(url);
        return false;
      }
      return true;
    }
  }

  ubyte[] post(string url, string payload, string type)
  {
    url = onlyPath(url);
    this.exec(HTTP.Method.post, url, cast(ubyte[]) payload, type);
    return res.data;
  }

  /* --- _privates --- */
  private string url; /// url of last request
  private ubyte[] upload; /// data to upload
  private HTTP httpReq; /// HTTP requester
  private Response res; /// response from last request

  private void exec(HTTP.Method meth, string url, ubyte[] payload = null, string type = null)
  {
    httpReq.method = meth;
    httpReq.url = url;
    this.url = url;
    httpReq.clearRequestHeaders();
    if (type)
      httpReq.addRequestHeader("Content-Type", type);
    if (payload)
    {
      httpReq.contentLength = payload.length;
      upload = cast(ubyte[]) payload;
    }
    httpReq.perform();
  }

  private string onlyPath(string url)
  {
    if (countUntil(url, "?") >= 0)
      url = url[0 .. countUntil(url, "?")];
    if (countUntil(url, "&") >= 0)
      url = url[0 .. countUntil(url, "&")];
    if (countUntil(url, "=") >= 0)
      url = url[0 .. countUntil(url, "=")];
    if (countUntil(url, "#") >= 0)
      url = url[0 .. countUntil(url, "#")];
    if (countUntil(url, ";") >= 0)
      url = url[0 .. countUntil(url, ";")];
    return url;
  }

  private string rel(string base, string href)
  {
    string root = url[0 .. countUntil(url[8 .. $] ~ "/", "/") + 8] ~ "/";
    string dir = url;
    if (href.length >= 2 && href[0 .. 2] == "//")
      href = root[0 .. countUntil(root, ":") + 1] ~ href;
    if (href.length >= 1 && href[0 .. 1] == "/")
      href = root[0 .. $ - 1] ~ href;
    if (!this.isUrl(href))
      href = dir ~ href;
    href = this.onlyPath(href);
    return href;
  }

  private void crawl(string url)
  {
    string root = url[0 .. countUntil(url[8 .. $] ~ "/", "/") + 8] ~ "/";
    string dir = url;
    while (dir.length > root.length && dir[$ - 1 .. $] != "/")
      dir = dir[0 .. $ - 1];
    string filename = this.actualFile(url);
    string htmlcode = readText(filename);
    if (htmlcode.length < 1 || htmlcode[0 .. 1] != "<")
      return;
    auto doc = createDocument(htmlcode);
    Node[] links;
    foreach (link; doc.querySelectorAll("[href]"))
      links ~= link;
    foreach (link; doc.querySelectorAll("[src]"))
      links ~= link;
    foreach (link; links)
    {
      string href = to!string(link.attr("href") ~ link.attr("src"));
      if (href.length >= 2 && href[0 .. 2] == "//")
        href = root[0 .. countUntil(root, ":") + 1] ~ href;
      if (href.length >= 1 && href[0 .. 1] == "/")
        href = root[0 .. $ - 1] ~ href;
      if (!this.isUrl(href))
        href = dir ~ href;
      href = this.onlyPath(href);
      if (href.length >= 1 && href[$ - 1 .. $] == "/")
        href ~= "~index";
      href = this.actualFile(href);
      if (!exists(dirName(href)))
        mkdirRecurse(dirName(href));
      if (baseName(href) != "~index.~file" && !exists(href))
        std.file.write(href, "");
    }
  }
}

class Response
{
  uint code;
  string[string] headers;
  ubyte[] data;
}
