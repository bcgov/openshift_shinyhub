To upload an entire folder in ASP.NET Core, use the HTML webkitdirectory attribute on the frontend to select a directory, and process the incoming IFormFileCollection on the backend while preserving each file's relative path.

1. Frontend (HTML Form / Razor View)

Add the webkitdirectory and multiple attributes to your file input so the browser allows folder selection and sends all nested files with their relative paths as their FileName.
html
<form asp-controller="Upload" asp-action="UploadFolder" method="post" enctype="multipart/form-data">
    <input type="file" name="files" webkitdirectory directory multiple />
    <button type="submit">Upload Folder</button>
</form>
Use code with caution.

2. Backend (ASP.NET Core Controller)

In your controller, accept IFormFileCollection, resolve the relative subfolder structure from file.FileName, and sanitize the path to prevent directory traversal attacks.
csharp
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("[controller]")]
public class UploadController : ControllerBase
{
    private readonly string _uploadRoot;

    public UploadController(IWebHostEnvironment env)
    {
        // Store uploads outside wwwroot in production for security
        _uploadRoot = Path.Combine(env.ContentRootPath, "Uploads");
    }

    [HttpPost("folder")]
    public async Task<IActionResult> UploadFolder([FromForm] IFormFileCollection files)
    {
        if (files == null || files.Count == 0)
            return BadRequest("No files received.");

        foreach (var file in files)
        {
            if (file.Length <= 0) continue;

            // file.FileName contains the relative path (e.g., "MyFolder/Subfolder/doc.pdf")
            var fullPath = Path.GetFullPath(Path.Combine(_uploadRoot, file.FileName));

            // Security check: prevent path traversal (e.g., "../../appsettings.json")
            if (!fullPath.StartsWith(_uploadRoot, StringComparison.OrdinalIgnoreCase))
                return BadRequest("Invalid file path detected.");

            // Recreate the subfolder structure if it doesn't exist
            Directory.CreateDirectory(Path.GetDirectoryName(fullPath)!);

            using var stream = new FileStream(fullPath, FileMode.Create);
            await file.CopyToAsync(stream);
        }

        return Ok(new { Count = files.Count, Message = "Folder uploaded successfully." });
    }
}
Use code with caution.

Important Considerations

• Request Size Limits: By default, ASP.NET Core limits multipart body lengths to ~128 MB and Kestrel limits requests to 30 MB. If uploading large folders, configure FormOptions and Kestrel limits in Program.cs:csharp
builder.Services.Configure<FormOptions>(options =>
{
    options.MultipartBodyLengthLimit = 524_288_000; // 500 MB
});
builder.WebHost.ConfigureKestrel(options =>
{
    options.Limits.MaxRequestBodySize = 524_288_000; // 500 MB
});
Use code with caution.
• Storage Security: Avoid saving user-uploaded folders directly inside wwwroot unless the files are meant to be publicly accessible without authorization. Always validate file extensions if you only accept specific formats.