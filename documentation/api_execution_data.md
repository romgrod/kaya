api Execution Data
============================


With Kaya you can add data to the execution. Then you can find that data through the API by using

    /kaya/api/results/<result id>/data

This will give you the JSON (a part of the result) with the data you setted while your execution was running.

---------------------------------------

How to add execution data
============================

Basically you have to add kaya gem to your project

    require 'kaya'

Before, you have to add it to your Gemfile

    # Gemfile
    gem 'kaya'


After adding the gem to your project, you can do:

    Kaya::Custom::ExecutionData.add("my_data_key", "some value for data key")


Once the execution it is finished, you can see the values through:

    http::/host:port/kaya/api/results/<result_id>/data

And you'll see something like:

    {
      type: "result",
      _id: 1427901370053,
      status: "stopped (Inactivity Timeout reached)",
      execution_data: {
        my_data_key: "some value for data key"
      }
    }


Think about this for integration tests.