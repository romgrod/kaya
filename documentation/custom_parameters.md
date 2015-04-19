How to pass parameters to a test suite execution?
==============

As Kaya retrieve information from suite's file called cucumber.yml allocated on projet root folder.

You can send parameters to a test suite execution and your tests can take that data to run in a certain way you need or want.

To ask for parameters into a test suite you have to set them up in cucumber.yml file.

There are basically two types of fields you can show in test suites (text field and select list).

This fields can be setted as required values and or with a default value.

All custom parameters must be defined on each test suite you need by using the custom parameter:

      #cucumber.yml

      regression: -t @regression runnable=true custom=[]

Text field
---------------------

To show a text field as a custom parameter you just have to define the name of the param

      regression: -t @regression runnable=true custom=[my_param]

<form>
  <label class="col-sm-2 control-label" for="formGroupInputSmall">my_param</label><input type="text" name="my_param" value="" placeholder="" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px;">
</form>

---------------------------------------

If you want to define a default value just define the value like:

      regression: -t @regression runnable=true custom=[my_param:a_value]

<form>
<label class="col-sm-2 control-label" for="formGroupInputSmall">my_param</label><input type="text" name="my_param" value="a_value" placeholder="" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px;">
</form>

---------------------------------------

You can define the parameter as a required value by using \*

      regression: -t @regression runnable=true custom=[my_param:*]

<form>
<label class="col-sm-2 control-label" for="formGroupInputSmall">my_param</label><input type="text" name="my_param" value="" placeholder="" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px;">*
</form>

---------------------------------------

You can also define the parameter as required and with a default value by using:

      regression: -t @regression runnable=true custom=[my_param:a_value:*]

<form>
<label class="col-sm-2 control-label" for="formGroupInputSmall">my_param</label><input type="text" name="my_param" value="a_value" placeholder="" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px;">*
</form>

Select List
---------------------

To provide a certain set of possible values that a test suite can use, you can provide a custom parameter as a select list
It is like a text field but just use () to provide the possible values separated by | (pipe char).

      regression: -t @regression runnable=true custom=[environment:(RC|IC|BETA|PROD)]

<form>
<label class="col-sm-2 control-label" for="formGroupInputSmall">environment</label><select id="environment" name="environment" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px;">  <option value="RC">RC</option>  <option value="IC">IC</option>  <option value="BETA">BETA</option>  <option value="PROD">PROD</option>  </select>
</form>

---------------------------------------

The first value on the list will be used as a default value if user does not select any other value from the list
With this type of parameter you will ensure that the execution will expect a correct value to run. This is used to make a parameter required with a list of possible values
---------------------------------------
But if you do not want to make a select list mandatory, you can use as a first value none to indicate the there is a null value. It is aimed to mimic that user does not select a value

      regression: -t @regression runnable=true custom=[environment:(none|RC|IC|BETA|PROD)]

      # none will be interpreted as an empty option, by using it at the first place on the list, you are setting this parameter as optional.

<form>
<label class="col-sm-2 control-label" for="formGroupInputSmall">environment</label><select id="environment" name="environment" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px;">  <option value=""></option> <option value="RC">RC</option>  <option value="IC">IC</option>  <option value="BETA">BETA</option>  <option value="PROD">PROD</option></select>
</form>

---------------------------------------





How to get custom parameters
==============

Once Kaya has got the custom parameters from cucumber.yml, you can get them whenever and wherever you want inside your code.
You'll can do it by creating an instance of Kaya::Custom::Params

For example
If you have defined a custom parameter like that: custom=[environment:(RC|PROD)]

So you will be able to get this parameter by the following way:

      $CUSTOM = Kaya::Custom::Params.get

      $CUSTOM.environment
      # => will return the selected choice of environment param by the user.

If you want to get all custom params in a hash you can use:

      $CUSTOM.all_params
      # will return a hash with all params and values {}

      $CUSTOM.raw
      # Same as .all_params

