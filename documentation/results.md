Results and details about them.
==============

Each Test Suite execution creates a result. You can see them in Results section.
You will see each Test Suite box with its results. If a Test Suite has more than three results, you'll see a green button that says `All results` for this test suite to see all results for that test suite
A result line looks like:

<div class="panel panel-primary">
  <div class="panel-heading" data-toggle="collapse" data-target="#at_world">
    <h3 class="panel-title">
      Regression Tests
      <div class="pull-right">28 Results</div>
    </h3>
  <div></div>
</div>
<div class="panel-body collapse in" id="at_world">
  <div title="Command: -t @multi "></div>
  <div title="Command: -t @multi "></div>
  <div title="Command: -t @multi "></div>
  <table class="table">
    <thead>
      <tr>
        <th style="font-weight: bold;">When</th>
        <th style="font-weight: bold;">Label</th>
        <th style="font-weight: bold;">Duration (sec)</th>
        <th style="font-weight: bold; text-align: center;">Unviewed</th>
        <th style="font-weight: bold;">Console</th>
        <th style="font-weight: bold;">Status</th>
      </tr>
    </thead>
    <tbody>
      <tr class="small">
        <th>01/04/2015 12:16:10</th>
        <th>01APR15-1216</th>
        <th> 5 m 2 s</th>
        <th style="text-align: center;">
          No
        </th>
        <th>
          <a class="label label-default">
            Console Log
          </a>
        </th>
        <th>
          <a href="#" class="label label-danger">Stopped (inactivity timeout reached)</a>
        </th>
      </tr>
      <tr class="small">
        <th>19/03/2015 16:00:30</th>
        <th>19MAR15-1600</th>
        <th>11 s</th>
        <th style="text-align: center;">
            No
        </th>
        <th>
          <a class="label label-default">
            Console Log
          </a>
        </th>
        <th>
          <a href="#" class="label label-success">1 scenario (1 passed) - 1 step (1 passed)</a>
        </th>
      </tr>
      <tr class="small">
        <th>19/03/2015 15:17:16</th>
        <th>19MAR15-1517</th>
        <th> 4 m 21 s</th>
        <th style="text-align: center;">
            No
        </th>
        <th>
          <a class="label label-default">
            Console Log
          </a>
        </th>
        <th>
          <a href="#" class="label label-success">1 scenario (1 passed) - 1 step (1 passed)</a>
        </th>
      </tr>
    </tbody>
  </table>
  <div class="text-center">
    <a class="btn btn-info">
      Go to suite
    </a>
    <a href="/kaya/results/suite/multi" class="btn btn-default">
      &nbsp;&nbsp;All results for this suite&nbsp;
      <span class="label label-info label-as-badge">
        3
      </span>
    </a>
  </div>
  </div>
</div>

---------------------------------------


You can click on this button to see the console output of the execution

<a  class="btn btn-info">Console Log</a>

---------------------------------------

When the execution is still running this label will be shown

<span class="label label-success">Running</span>

---------------------------------------

You can click on summary description like this to see the cucumber report.

<span class="label label-success">4 scenarios (4 passed) - 20 steps (20 passed)</span>

---------------------------------------

When an execution is stopped you'll see this in All Results section you'll see all execution results for all test suites. You can find a specific result by typing a keyword or selecting a status and pressing Search

<span class="label label-danger">Suite execution stopped!</span>