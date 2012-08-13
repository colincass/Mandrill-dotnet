require 'albacore'
require 'version_bumper'

task :deploy => [:zip, :nup] do
end

zip :zip => :output do | zip |
    zip.directories_to_zip "out"
    zip.output_file = "PostageApp.v#{bumper_version.to_s}.zip"
    zip.output_path = "build"
end

output :output => :test do |out|
	out.from '.'
	out.to 'out'
	out.file 'src/bin/release/PostageApp.dll', :as=>'PostageApp.dll'
	out.file 'LICENSE.txt'
	out.file 'README.md'
	out.file 'VERSION'
	# output can also build a nuspec :) 
	# out.erb 'build/nchurn.nuspec.erb', :as => 'nchurn.nuspec', :locals => { :version => bumper_version }
end

desc "Test"
nunit :test => :build do |nunit|
	nunit.command = "tools/NUnit/nunit-console.exe"
	nunit.assemblies "tests/bin/release/PostageApp.Tests.dll"
end

desc "Build"
msbuild :build => :assemblyinfo do |msb|
  msb.properties :configuration => :Release
  msb.targets :Clean, :Build
  msb.solution = "PostageApp.sln"
end

nugetpack :nup => :nus do |nuget|
   nuget.command     = "tools/NuGet/NuGet.exe"
   nuget.nuspec      = "PostageApp.nuspec"
   nuget.base_folder = "out/"
   nuget.output      = "build/"
end

nuspec :nus => :output do |nuspec|
   nuspec.id="PostageApp"
   nuspec.version = bumper_version.to_s
   nuspec.authors = "Shawn Mclean"
   nuspec.description = "PostageApp .Net is a wrapper for the PostageApp API."
   nuspec.title = "PostageApp"
   nuspec.language = "en-US"
   nuspec.projectUrl = "https://github.com/shawnmclean/PostageApp-dotnet"
   nuspec.working_directory = "out/"
   nuspec.output_file = "PostageApp.nuspec"
   nuspec.file "PostageApp.dll", "lib"
end


assemblyinfo :assemblyinfo do |asm|
  asm.version = bumper_version.to_s
  asm.file_version = bumper_version.to_s

  asm.company_name = "Self"
  asm.product_name = "PostageApp"
  asm.copyright = "Shawn Mclean (c) 2012"
  asm.output_file = "AssemblyInfo.cs"
end