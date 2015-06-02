How to use Test Suites in Kaya?
==============

You can find test tasks on Test Suites section.
Kaya will retrieve all profiles masked as runnable defined on cucumber.yml
Each Test Suite can be executed by pressing Run button. The execution result could be identified after the execution by adding a label before pressing Run button
For example, an identifier could be a release product version like r2.3.44. So you will be able to identify quickly the execution result later
You can provide some parameters to the execution by using [Custom Parameters](/kaya/help/custom_parameters "Custom Parameters")

A Test Suite looks like:
---------------------

<div class="panel panel-primary">
  <div class="panel-heading" data-toggle="collapse" data-target="#multi">
    <h4 class="panel-title">multi</h4>
  </div>
  <div class="panel-body collapse in" id="multi">
    <ul class="list-group">
      <li class="list-group-item">Command: -t @multi</li>
      <li class="list-group-item">Last result:&nbsp;<a href="#" class="label label-danger" >Stopped (inactivity timeout reached)</a></li>
      <li class="list-group-item">Started on:&nbsp;24/05/47218 02:27:33</li>
      <li class="list-group-item">
        <form name="run" id="multi" method="get" action="#">
          <h4 title="This parameters will be passed to the test task execution">&nbsp;&nbsp;&nbsp;Custom Parameters</h4>
          <div class="container" style="width: inherit">
          <li class="list-group-item" style="position:relative; with=100%">
            <div class="form-group-sm">
              <label class="col-sm-2 control-label" for="formGroupInputSmall">environment</label>
              <select id="environment" name="environment" class="customParam" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px; font-weight:normal;">
                <option value="RC">RC</option>
                <option value="BETA">BETA</option>
                <option value="PROD">PROD</option>
              </select>
              <input type="text" id="otro0" name="otro" value="Enter otro" onfocus="if (this.value==&quot;Enter otro&quot;) this.value=&quot;&quot;;" placeholder="" style="display: none; height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px;"></div>
              <div class="form-group-sm">
                <label class="col-sm-2 control-label" for="formGroupInputSmall">my param A</label>
                <textarea class="customParam" type="text" name="blabla" placeholder="" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px; max-width: 70%; max-height: 500px; min-height: 34px; min-width: 212px; font-weight:normal;"></textarea>
              </div>
              <div class="form-group-sm">
                <label class="col-sm-2 control-label" for="formGroupInputSmall">my param B</label>
                  <textarea class="customParam" type="text" name="etc" placeholder="" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px; max-width: 70%; max-height: 500px; min-height: 34px; min-width: 212px; font-weight:normal;"></textarea>
              </div>
              <div class="form-group-sm">
                <label class="col-sm-2 control-label" for="formGroupInputSmall">my Param C</label>
                <textarea class="customParam" type="text" name="country" placeholder="" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px; max-width: 70%; max-height: 500px; min-height: 34px; min-width: 212px; font-weight:normal;"></textarea>
              </div>
            </li>
          </div>
          <br><br>
            <input type="submit" class="btn btn-success" value="Execute Suite">&nbsp;
            <input type="text" name="execution_name" class="customParam" title="This value could be used to identify the result execution from other execution of this task. E.g: You could use the release your are going to test" placeholder="Identify your execution" value="01APR15-1356" style="height: 34px; padding: 6px 12px; font-size: 14px; line-height: 1.42857143; color: #555; background-color: #fff; background-image: none; border: 1px solid #ccc; border-radius: 4px; font-weight:normal;">
            <button type="button" class="btn btn-default" aria-label="Left Align" data-toggle="modal" data-target="#myModal" onclick="javascript:starter_link(&quot;multi&quot;);">
              <span class="glyphicon glyphicon-star" aria-hidden="true">Link</span>
            </button>
          </form>
        </li>
      </ul>
      <a href="#" class="btn btn-default pull-center">All results(28)</a>
    </div>
  </div>