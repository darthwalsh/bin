using System;
// using System.Diagnostics;
using System.IO;
// using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

public class GpxUpload 
{
  static HttpClient client = new HttpClient();

  public static string OsmAuth() {
    string osmPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".rtg", "osm.txt");
    if (File.Exists(osmPath)) return File.ReadAllText(osmPath);

    Console.WriteLine("Type OSM username:password");
    var userpass = Console.ReadLine() ?? throw new ArgumentNullException();
    File.WriteAllText(osmPath, userpass);
    return userpass;
  }

  public static async Task<int> Run(string path, DateTime start)
  {
    // https://wiki.openstreetmap.org/wiki/API_v0.6#Create:_POST_.2Fapi.2F0.6.2Fgpx.2Fcreate

    using var multiContent = new MultipartFormDataContent();

    using var gxp = File.OpenRead(path);
    using var file = new StreamContent(gxp);
    multiContent.Add(file, "file", Path.GetFileName(path));

    using var description = new StringContent($"Run {start:yyyy-MM-dd} looking for paths");
    multiContent.Add(description, "description");

    using var tags = new StringContent("");
    multiContent.Add(tags, "tags");

    using var visibility = new StringContent("trackable");
    multiContent.Add(visibility, "visibility");

    using var request = new HttpRequestMessage
    {
      Method = HttpMethod.Post,
      Content = multiContent,
      RequestUri = new Uri("https://api.openstreetmap.org/api/0.6/gpx/create"),
    };

    string base64 = Convert.ToBase64String(System.Text.ASCIIEncoding.ASCII.GetBytes(OsmAuth()));
    request.Headers.Authorization = new AuthenticationHeaderValue("Basic", base64);

    using var response = await client.SendAsync(request);
    response.EnsureSuccessStatusCode();

    var id = await response.Content.ReadAsStringAsync();
    return int.Parse(id);
  }
}
