using Cake.Common;
using Cake.Common.Diagnostics;
using Cake.Common.Tools.GitVersion;
using Cake.Core;

public class BuildVersion
{
    public string Version { get; private set; }
    public string Suffix { get; private set; }

    public BuildVersion(string version, string suffix)
    {
        Version = version;
        Suffix = suffix;

        if(string.IsNullOrWhiteSpace(Suffix))
        {
            Suffix = null;
        }
    }

    public static BuildVersion Calculate(Context context)
    {
        string version = null;
        string semVersion = null;

        if (context.IsRunningOnWindows())
        {
            context.Information("Calculating semantic version...");
            if (!context.IsLocalBuild)
            {
                context.GitVersion(new GitVersionSettings
                {
                    OutputType = GitVersionOutput.BuildServer
                });
            }

            GitVersion assertedVersions = context.GitVersion(new GitVersionSettings
            {
                OutputType = GitVersionOutput.Json
            });
            version = assertedVersions.MajorMinorPatch;
            semVersion = assertedVersions.LegacySemVerPadded;
        }

        if (string.IsNullOrWhiteSpace(version))
        {
            throw new CakeException("Could not calculate version of build.");
        }

        return new BuildVersion(version, semVersion.Substring(version.Length).TrimStart('-'));
    }
}