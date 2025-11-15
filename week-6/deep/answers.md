# From the Deep

In this problem, you'll write freeform responses to the questions provided in the specification.

## Random Partitioning

Random partitioning makes the data evenly distributed among the boats and is straightforward to implement. But time based query of the data will become inefficient, costly and cause higher latency.

## Partitioning by Hour

Hour-based partitioning makes time-range queries and specific-timestamp queries faster and simpler. But because some hours have far more observations than others, certain boats will receive much more data, creating storage and load imbalance. This uneven distribution is the main drawback of this approach.

## Partitioning by Hash Value

Hash partitioning evenly distributes data and makes finding a specific timestamp fast. But time range queries remain inefficient because nearby timestamps can be stored on different boats. So, range queries still require scanning all boats.
