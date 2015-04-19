How do i use the api?
==============


Well, we want to do things as simple as possible, so we are using only GET requests. Everyone has a browser, so everyone has the possiblility to use Kaya.

Returns the list of suites

    kaya/api/suites

Returns the list of suites that are running

    kaya/api/suites/running

Returns the status of the given suite id

    kaya/api/suites/<suite_id>/status

Returns the suite structure for the given suite id

    kaya/api/suites/<suite_id>

Returns all existing results

    kaya/api/results

Returns the result for a given result id

    kaya/api/results/<result_id>

Starts an execution

  Perform get to:

    kaya/api/suites/<suite_me>/run

    # pass custom parameters as query string like vkaya/api/suites/:suite/run?environment=RC&foo=bar

    # and if you want identify the execution, you can pass execution_name=your_execution_identification' as query string too.

  If execution starts succesfully, it will return a result id


Returns the execution data for a given result id

    kaya/api/results/<result_id>/data

