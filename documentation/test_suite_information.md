How to provide information about a test suite?
==============

You can provide some information about a test suite by adding info value to each suite you need

      #cucumber.yml 
      regression: -t @regression info=[This is to execute a regression tests suite]

This value `info=[Explaining text]` will show the icon <span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span> where you can mouse over and read the text 