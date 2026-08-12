# Modernizing ERP analytics using ELT Architecture

## Overview
ERP systems are massive, they have mostly over 1000 tables intertwined and inter-dependent. ERPNext is not an exception to this.
As the volume of transactions continue to grow from hundreds of thousands or rows to millions of rows, direct BI connection to the operational database becomes leads to performance and limited scalability.

The increasing volume of data and complexity of analytics leads to performance bottlenecks in the OLTP database, and suboptimal query performance. 
Furthermore, operational databases such as MariaDB (MySQL) used by ERPNext is mean for OLTP functions and not optimized for OLAP functions.

This is where data engineering comes in by designing and maintaining data pipelines that extract, load and transform the data from the source OLTP database
into optimized datawarehouse. By spliting the OLTP and OLAP functions, we are able to opimize data workflows, transform and aggregate data for analytical tasks 
effectively without affecting the OLAP functions.

