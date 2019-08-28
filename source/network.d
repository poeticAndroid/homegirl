module network;

import std.file;
import std.path;
import std.digest.md;
import std.conv;
import std.uri;
import std.algorithm;
import requests;
import html;

/**
  Networking system
*/
class Network
{
  string cacheDir; /// path to cache folder
  Request req; /// request

  /**
    create network
  */
  this(string cacheDir)
  {
    this.cacheDir = buildNormalizedPath(cacheDir) ~ "/";
    if (!exists(this.cacheDir))
      mkdirRecurse(this.cacheDir);
    this.req = Request();
    this.req.sslSetCaCert("./cacert.pem");
  }

  bool isUrl(string url)
  {
    if (url && url.length < 8)
      return false;
    if (url[0 .. 7] == "http://")
      return true;
    if (url[0 .. 8] == "https://")
      return true;
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
    // string filename = this.cacheDir ~ to!string(hexDigest!MD5(url)) ~ suff;
    return filename;
  }

  string get(string url)
  {
    url = onlyPath(url);
    string filename = this.actualFile(url);
    Response res = req.get(url);
    url = res.finalURI.recalc_uri();
    if (res.code < 300)
    {
      if (!exists(dirName(filename)))
        mkdirRecurse(dirName(filename));
      std.file.write(filename, res.responseBody.data);
      try
      {
        this.crawl(url);
      }
      catch (Exception err)
      {
      }
    }
    else if (exists(filename))
      remove(filename);
    return filename;
  }

  /* --- _privates --- */

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

  private void crawl(string url)
  {
    string root = url[0 .. countUntil(url[8 .. $] ~ "/", "/") + 8] ~ "/";
    string dir = url;
    while (dir.length > root.length && dir[$ - 1 .. $] != "/")
      dir = dir[0 .. $ - 1];
    string filename = this.actualFile(url);
    string htmlcode = readText(filename);
    if (htmlcode[0 .. 1] != "<")
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
