using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

namespace DeltaCardInstaller
{
    internal static class Program
    {
        [STAThread]
        private static void Main()
        {
            try
            {
                StopGameBarProcesses();

                var installDirectory = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "DeltaCardWidget");
                var temporaryZip = Path.Combine(Path.GetTempPath(), Guid.NewGuid() + ".zip");
                var resource = Assembly.GetExecutingAssembly().GetManifestResourceStream("payload.zip");
                if (resource == null)
                {
                    throw new InvalidOperationException("The installer payload is missing.");
                }

                using (resource)
                using (var archiveFile = File.Create(temporaryZip))
                {
                    resource.CopyTo(archiveFile);
                }

                try
                {
                    if (Directory.Exists(installDirectory))
                    {
                        Directory.Delete(installDirectory, recursive: true);
                    }
                    Directory.CreateDirectory(installDirectory);
                    ZipFile.ExtractToDirectory(temporaryZip, installDirectory);
                }
                finally
                {
                    File.Delete(temporaryZip);
                }

                var powerShell = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.System),
                    "WindowsPowerShell", "v1.0", "powershell.exe");
                var scriptPath = Path.Combine(installDirectory, "Install.ps1");
                var startInfo = new ProcessStartInfo(powerShell)
                {
                    Arguments = "-NoProfile -ExecutionPolicy Bypass -File \"" + scriptPath + "\"",
                    WorkingDirectory = installDirectory,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                };

                using (var process = Process.Start(startInfo))
                {
                    if (process == null)
                    {
                        throw new InvalidOperationException("Could not start the installer script.");
                    }

                    var output = new StringBuilder();
                    var error = new StringBuilder();
                    process.OutputDataReceived += (sender, args) =>
                    {
                        if (args.Data != null) output.AppendLine(args.Data);
                    };
                    process.ErrorDataReceived += (sender, args) =>
                    {
                        if (args.Data != null) error.AppendLine(args.Data);
                    };
                    process.BeginOutputReadLine();
                    process.BeginErrorReadLine();
                    process.WaitForExit();
                    process.WaitForExit();

                    if (process.ExitCode != 0)
                    {
                        throw new InvalidOperationException(error.Length == 0 ? output.ToString() : error.ToString());
                    }
                }

                MessageBox.Show(
                    "Installed. Press Win+G and open the widget menu.\n\n" + installDirectory,
                    "DeltaCardWidget",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception exception)
            {
                MessageBox.Show(
                    "Installation failed. Make sure Developer Mode is enabled.\n\n" + exception.Message,
                    "DeltaCardWidget",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                Environment.ExitCode = 1;
            }
        }

        private static void StopGameBarProcesses()
        {
            foreach (var process in Process.GetProcesses())
            {
                try
                {
                    if (process.ProcessName.Equals("DeltaCard", StringComparison.OrdinalIgnoreCase)
                        || process.ProcessName.StartsWith("GameBar", StringComparison.OrdinalIgnoreCase))
                    {
                        process.Kill();
                        process.WaitForExit(5000);
                    }
                }
                catch (InvalidOperationException)
                {
                }
                catch (System.ComponentModel.Win32Exception)
                {
                }
                finally
                {
                    process.Dispose();
                }
            }
        }
    }
}