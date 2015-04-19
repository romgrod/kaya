Feature: Installing Kaya on a Cucumber project
  As a Cucumber user
  When I install kaya on the project
  I have to see a folder inside the root project folder

# ASSUME THAT REQUIREMENTS ARE INSTALLED ON THE SYSTEM

Background: A cucumber project must exist on a folder
  Given ensure that a cucumber project exist

Scenario: Installing Kaya on a project without requirements on the system
  Given kaya gem is installed on the system
  When I run 'install' kaya command
  Then a folder called kaya should be added to the project
  And kaya folder must have the following files
  |kaya_conf|kaya_log|unicorn.rb|sidekiq_log|config.ru|
  And kaya folder must have the following folders
  |temp|