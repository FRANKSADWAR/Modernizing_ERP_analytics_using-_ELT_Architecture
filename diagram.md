
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
