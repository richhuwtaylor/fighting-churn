# Fighting Churn with Data

This project demonstrates how the usage and subsciption data or a product or service can be combined identify user behaviours which predict customer churn. This analysis can then be used to suggest tactics to fight churn.

The SQL and python scripts included in this repo are intended to be used on the simulated social network 'SocialNet7' dataset which can be generated by running the setup of [fight-churn](https://www.manning.com/books/fighting-churn-with-data) for the book [Fighting Churn with Data](https://www.manning.com/books/fighting-churn-with-data) by Carl Gold. 

The SQL scripts and Python notebooks of this project follow the natural order of any effort to combat churn. They should be followed and executed in order. Any intermediate outputs are held in the [output](./output/) folder.

### Part 1 ###
- [churn-calculations](./part1/churn-calculations/) includes SQL scripts for calculating:
    - activity event based churn
    - MRR churn
    - net retention
    - standard account-based churn
- [insert-metrics](./part1/insert-metrics/) includes a SQL script for inserting aggregated metrics for each kind of analytics event.
- [event-quality-assurance](./part1/event-quality-assurance/) contains a notebook and SQL scripts for plotting events over time.
- [metric-quality-assurance](./part1/metric-quality-assurance/) contains a notebook and SQL scripts for spotting anomalous metric values which might indicate problems with event collection.
- [account-tenure](./part1/account-tenure/) contains scripts for calculating account tenure (the length of time for which there is a continuous subscription for a single account) and inserting this into the data warehouse as its own metric.
- [identify-active-periods](./part1/identify-active-periods/) contains SQL scripts for calculating the active periods (allowing for a maximum 7 day gap between subscriptions) and inserting these into an `active_period` table. These are used to determine whether or not a metric observation ended in churn.
- [create-churn-dataset](./part1/create-churn-dataset/) is where the the fun begins! Here, we create a dataset of 'per-month' event metric observations which form the basis of our churn analysis.

### Part 2 ###
- [metric-summary-stats](./part2/metric-summary-stats/) contains a notebook for checking summary statistics for all metrics (so that we can check the percentage of zero-values).
- [metric-scores](./part2/metric-scores/) contains a notebook for producing normalised ("scored") versions of each event metric.
- [metric-cohorts](./part2/metric-cohorts/) contains notebooks for performing cohort analysis on inidividual and grouped versions of our metrics.
- [metric-correlations](./part2/metric-correlations/) contains a notebook for calculating and visualising the matrix of Pearson correlation coefficients between metrics.
- [group-behavioural-metrics](./part2/group-behavioural-metrics/) contains notebooks for:
    - grouping metrics together using hierarchical clustering and generating a loading matrix for averaging together the scores of those groups
    - applying the loading matrix to create grouped scores.

The subscription data, analytics data and the churn metrics produced from them are stored locally in a PostgreSQL database.