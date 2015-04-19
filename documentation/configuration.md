How to configure Kaya?
==============

Kaya retrieve information from profiles file called cucumber.yml allocated on project root folder.
You have to have this file into your project to work with Kaya.

Kaya will show only those suites marked as runnable as test suites. To do this you only have to add a flag to each cucumber profile you want to expose as follows:
Supose you have a profile called regression on cucumber.yml file

	#cucumber.yml
	regression: -t @regression runnable=true

The flag `runnable=true` indicates to Kaya to expose the profile to be executed as a test suite.