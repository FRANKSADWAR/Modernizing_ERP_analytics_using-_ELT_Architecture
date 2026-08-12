# Modernizing ERP analytics using ELT Architecture

## Overview
ERP systems are massive, they have mostly over 1000 tables intertwined and inter-dependent. ERPNext is not an exception to this.
As the volume of transactions continue to grow from hundreds of thousands or rows to millions of rows, direct BI connection to the operational database becomes leads to performance and limited scalability.

The increasing volume of data and complexity of analytics leads to performance bottlenecks in the OLTP database, and suboptimal query performance. 
Furthermore, operational databases such as MariaDB (MySQL) used by ERPNext is mean for OLTP functions and not optimized for OLAP functions.

This is where data engineering comes in by designing and maintaining data pipelines that extract, load and transform the data from the source OLTP database
into optimized datawarehouse. By spliting the OLTP and OLAP functions, we are able to opimize data workflows, transform and aggregate data for analytical tasks 
effectively without affecting the OLAP functions.

## Architecture Overview
flowchart TD
    subgraph VPS["Linux Virtual Private Server (Bare-Metal / Systemd)"]
        
        subgraph SourceLayer["1. Source Layer"]
            ERP[("ERPNext Database\n(MariaDB / Postgres)\nOLTP Engine")]
        end

        subgraph OrchestrationLayer["Orchestration Engine"]
            Airflow["Apache Airflow\n(Systemd / Python Service)\nScheduler & Task Manager"]
        end

        subgraph ExtractionLayer["2. Extract & Load (Raw)"]
            PyScript["Python Extraction Script\n(Pandas / PyArrow)"]
            MinIO[("MinIO Object Storage\n(Systemd / Local Disk)\nRaw Layer: Parquet Format")]
        end

        subgraph ProcessingLayer["3. Ingestion & Transformation"]
            DuckDB["DuckDB\n(In-Memory Analytical Engine)\nIngests S3 Parquet to Postgres"]
            PG_Warehouse[("PostgreSQL\n(Relational Data Warehouse)")]
            
            subgraph PG_Schemas["PostgreSQL Schemas"]
                RawSchema["raw_erpnext\n(Raw Ingested Data)"]
                StgSchema["stg_erpnext\n(Cleaned & Standardized)"]
                GoldSchema["analytics_gold\n(Dimensional Fact & Dim Tables)"]
            end
            
            DBT["dbt Core\n(SQL Data Build Tool)\nModels & Lineage Transformations"]
        end

        subgraph BI Layer["4. Presentation & Analytics"]
            Metabase["Metabase\n(Business Intelligence)\nDashboards & Analytics"]
        end
    end

    %% Data Pipeline Flow
    ERP -->|"1. PyMySQL / SQLAlchemy Read"| PyScript
    PyScript -->|"2. Write Raw Parquet Objects"| MinIO
    MinIO -->|"3. HTTP/S3 Parquet Streaming"| DuckDB
    DuckDB -->|"4. Fast Relational Bulk Copy"| RawSchema
    
    RawSchema --> PG_Warehouse
    StgSchema --> PG_Warehouse
    GoldSchema --> PG_Warehouse

    DBT -->|"5. Reads Raw, Executes SQL Transforms"| RawSchema
    DBT -->|"6. Builds Staging Views & Gold Fact Tables"| StgSchema
    DBT --> GoldSchema

    GoldSchema -->|"7. Analytical SQL Queries"| Metabase

    %% Orchestration Control Loops
    Airflow -.-|"Triggers & Monitors"| PyScript
    Airflow -.-|"Triggers & Monitors"| DuckDB
    Airflow -.-|"Triggers & Monitors"| DBT