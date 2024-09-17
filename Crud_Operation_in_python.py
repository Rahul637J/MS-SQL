
'''

@Author: Rahul 
@Date: 2024-09-02
@Last Modified by: Rahul 
@Last Modified time: 2024-09-02
@Title: Employee wages - Crud operation in database using MS-Sql.  

'''


import pyodbc as db
import pandas as pd

class MSSql:
    
    connection = None
    current_database = None
    
    @staticmethod
    def create_Connection():
        
        """
        Description:
            The function to create a connection with the SQL Server database.
        Parameters:
            None.
        Return Type:
            connection (Connection): Returns the connection object.
        """
        
        try:
            connection_str = "Driver={ODBC Driver 17 for SQL Server};Server=GURUNADHA\\SQLExpress;Trusted_Connection=yes;"
            MSSql.connection = db.connect(connection_str)
            print("Connected to SQL Server successfully.\n")
            return MSSql.connection
        
        except Exception as e:
            print(f"Error in connection: {e}")
            return None
        
        
    
    @staticmethod
    def get_Databases():
        
        """
        Description:
            Fetches and displays all user-created databases, excluding system databases.
        Parameters:
            None.
        Return Type:
            None.
        """
        
        if MSSql.connection:
            
            try:
                cursor = MSSql.connection.cursor()
                query = """
                SELECT name 
                FROM sys.databases 
                WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');
                """
                cursor.execute(query)
                databases = cursor.fetchall()
                
                print("Databases:")
                for db_name in databases:
                    print(f" - {db_name[0]}")
                    
            except Exception as e:
                print(f"Error retrieving databases: {e}")
                
            finally:
                cursor.close()
                
        else:
            print("No connection to the database.")
            
            
    
    @staticmethod
    def use_Database(database_name):
        
        """
        Description:
            Switches the connection to a specified database.
        Parameters:
            database_name (str): The name of the database to switch to.
        Return Type:
            None.
        """
        
        if MSSql.connection:
            try:
                MSSql.current_database = database_name
                MSSql.connection.autocommit = True 
                cursor = MSSql.connection.cursor()
                cursor.execute(f"USE {database_name};")
                print(f"Switched to database '{database_name}'.")
                
            except Exception as e:
                print(f"Error switching database: {e}")
                
                
    
    @staticmethod
    def create_Database(database_name):
        
        """
        Description:
            Creates a new database with the specified name.
        Parameters:
            database_name (str): The name of the new database to create.
        Return Type:
            None.
        """
        
        if MSSql.connection:
            try:
                cursor = MSSql.connection.cursor()
                create_db_query = f"CREATE DATABASE {database_name};"
                cursor.execute(create_db_query)
                print(f"Database '{database_name}' created successfully.")
                
            except Exception as e:
                print(f"Error creating database: {e}")
                
                
                
    
    @staticmethod    
    def create_Table():
        
        """
        Description:
            Creates a new table in the currently selected database based on user input.
        Parameters:
            None.
        Return Type:
            None.
        """
        
        if MSSql.current_database:
            cursor = MSSql.connection.cursor() 
            table_name = input("Enter the Table name to create: ")
            columns = []
            num_columns = int(input("Enter the number of columns: "))
            
            for i in range(num_columns):
                column_name = input(f"Enter the name of column {i+1}: ")
                data_type = input(f"Enter the data type with the constraint you want for {column_name} (e.g., INT NOT NULL PRIMARY KEY, VARCHAR(100)): ")
                columns.append(f"{column_name} {data_type}")
            column_definitions = ", ".join(columns)
            create_table_sql = f"CREATE TABLE {table_name} ({column_definitions});"
            
            try:
                cursor.execute(create_table_sql)
                MSSql.connection.commit()  
                print(f"Table '{table_name}' created successfully.")
                
            except Exception as e:
                print(f"Error creating table: {e}")
                
            finally:
                cursor.close()
        else:
            print("No database selected. Please select a database first.")
    


    @staticmethod
    def alter_Column(table_name):
        
        """
        Description:
            Alters a non-primary key column in the specified table based on user input.
        Parameters:
            table_name (str): The name of the table where the column needs to be altered.
        Return Type:
            None.
        """
        
        if MSSql.current_database:
            try:
                cursor = MSSql.connection.cursor()
                
                cursor.execute(f"""
                    SELECT COLUMN_NAME 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = '{table_name}' 
                    AND COLUMN_NAME NOT IN (
                        SELECT COLUMN_NAME
                        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
                        WHERE TABLE_NAME = '{table_name}'
                        AND CONSTRAINT_NAME = (
                            SELECT CONSTRAINT_NAME
                            FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
                            WHERE TABLE_NAME = '{table_name}'
                            AND CONSTRAINT_TYPE = 'PRIMARY KEY'
                        )
                    );
                """)
                
                columns = cursor.fetchall()
                
                if not columns:
                    print(f"No alterable columns found in table '{table_name}'.")
                    return
                
                column_names = [col[0] for col in columns]
                print(f"Columns available for alteration: {column_names}")
                
                column_to_alter = input("Enter the column name you want to alter: ")
                if column_to_alter not in column_names:
                    print("Error: The specified column is either a primary key or does not exist.")
                    return
                
                new_data_type = input(f"Enter the new data type with constraints for {column_to_alter} (e.g., VARCHAR(255)): ")
                
                alter_column_sql = f"ALTER TABLE {table_name} ALTER COLUMN {column_to_alter} {new_data_type};"
                cursor.execute(alter_column_sql)
                MSSql.connection.commit()
                print(f"Column '{column_to_alter}' altered successfully.")
                
            except Exception as e:
                print(f"Error altering column: {e}")
            finally:
                cursor.close()
        else:
            print("No database selected. Please select a database first.")   
            
                 
            
    @staticmethod
    def get_Tables():
        
        """
        Description:
            Fetches and displays all the base tables in the current database.
        Parameters:
            None.
        Return Type:
            None.
        """
        
        if MSSql.connection:
            try:
                cursor = MSSql.connection.cursor()
                query = """
                SELECT TABLE_NAME 
                FROM INFORMATION_SCHEMA.TABLES 
                WHERE TABLE_TYPE = 'BASE TABLE';
                """
                cursor.execute(query)
                tables = cursor.fetchall()
                print("Tables in the current database:")
                for table in tables:
                    print(f" - {table[0]}")
                    
            except Exception as e:
                print(f"Error retrieving tables: {e}")
                
            finally:
                cursor.close()
                
        else:
            print("No database selected. Please select a database first.")        
    
    @staticmethod
    def display_Table_Records(table_name):
        
        """
        Description:
            Fetches and displays all records from the specified table using pandas DataFrame.
        Parameters:
            table_name (str): The name of the table from which to fetch and display records.
        Return Type:
            None.
        """
        
        if MSSql.connection:
            
            try:
                query = f"SELECT * FROM {table_name};"
                cursor = MSSql.connection.cursor()
                cursor.execute(query)
                columns = [column[0] for column in cursor.description]
                rows = cursor.fetchall()
                df = pd.DataFrame.from_records(rows, columns=columns)
                print(f"Records from '{table_name}' table:")
                print(df)
                
            except Exception as e:
                print(f"Error fetching records from table '{table_name}': {e}")
                
            finally:
                cursor.close()
        else:
            print("No database selected. Please select a database first.")
        
    @staticmethod
    def insert_Into_Table(table_name):
        
        """
        Description:
            Inserts a row of data into the specified table.
        Parameters:
            table_name (str): The name of the table to insert data into.
        Return Type:
            None.
        """
        
        if MSSql.current_database:
            cursor = MSSql.connection.cursor() 
            
            try:
                cursor.execute(f"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}';")
                columns = cursor.fetchall()
                
                if not columns:
                    print(f"Table '{table_name}' does not exist or has no columns.")
                    return
                
                column_names = [col[0] for col in columns]
                values = input(f"Enter the values for columns {column_names} separated by commas (e.g., value1, value2, value3): ")
                values = [val.strip() for val in values.split(',')]
                
                if len(column_names) != len(values):
                    print("Error: The number of columns and values do not match.")
                    return
                
                column_names_str = ", ".join(column_names)
                placeholders = ", ".join(["?"] * len(values))
                insert_sql = f"INSERT INTO {table_name} ({column_names_str}) VALUES ({placeholders});"
                cursor.execute(insert_sql, values)
                MSSql.connection.commit() 
                print("Data inserted successfully.")
                
            except Exception as e:
                print(f"Error inserting data: {e}")
                
            finally:
                cursor.close()
        else:
            print("No database selected. Please select a database first.")

    
    
    @staticmethod
    def update_Table(table_name):
        
        """
        Description:
            Updates a record in the specified table by user input.
        Parameters:
            table_name (str): The name of the table to update.
        Return Type:
            None.
        """
        
        if MSSql.connection:
            
            try:
                MSSql.display_Table_Records(table_name)
                column_to_update = input("Enter the column name you want to update: ")
                new_value = input(f"Enter the new value for {column_to_update}: ")
                condition_column = input("Enter the column name for the condition: ")
                condition_value = input(f"Enter the value of {condition_column} to match: ")
                update_query = f"""
                UPDATE {table_name}
                SET {column_to_update} = ?
                WHERE {condition_column} = ?;
                """
                cursor = MSSql.connection.cursor()
                cursor.execute(update_query, (new_value, condition_value))
                MSSql.connection.commit()
                print(f"Record(s) in '{table_name}' updated successfully.")
                
                MSSql.display_Table_Records(table_name)
                
            except Exception as e:
                print(f"Error updating records in table '{table_name}': {e}")
                
            finally:
                cursor.close()



    @staticmethod
    def delete_Record_In_Table(table_name):
        
        """
        Description:
            Deletes a record from the specified table by user input.
        Parameters:
            table_name (str): The name of the table to delete from.
        Return Type:
            None.
        """
        
        if MSSql.connection:
            
            try:
                MSSql.display_Table_Records(table_name)
                condition_column = input("Enter the column name for the condition to delete: ")
                condition_value = input(f"Enter the value of {condition_column} to match: ")
                delete_query = f"DELETE FROM {table_name} WHERE {condition_column} = ?;"
                cursor = MSSql.connection.cursor()
                cursor.execute(delete_query, (condition_value,))
                MSSql.connection.commit()
                print(f"Record(s) from '{table_name}' deleted successfully.")
                
                MSSql.display_Table_Records(table_name)
                
            except Exception as e:
                print(f"Error deleting records from table '{table_name}': {e}")
                
            finally:
                cursor.close()

            
            
            
def main():

    print("-"*45+"\n| CRUD Operation in MS SQL Server by Python |\n"+"-"*45)
    
    MSSql.create_Connection()
    
    if MSSql.connection:
        
        while True:
            
            db_option = input("Enter\n" +
                              "1) Create a new database\n" +
                              "2) Work with an existing database\n" +
                              "3) To Exit\n" +
                              "Option: ")
            
            if db_option == '1':
                database_name = input("Enter the name of the database to create: ")
                MSSql.create_Database(database_name)
                
            elif db_option == '2':
                MSSql.get_Databases()
                database_name = input("Enter the name of the existing database: ")
                MSSql.use_Database(database_name)
            
            elif db_option == '3':
                print("Exiting...")
                break    
                
            else:
                print("Invalid option. Please choose 1, 2, or 3.")
                continue

            while True:
                option = input("Enter \n" +
                               "1. To create a table\n" +
                               "2. To insert values into a table\n" +
                               "3. To update a table\n" +
                               "4. To delete a record from a table\n" +
                               "5. To exit\n" +
                               "Option: ")
                
                if option == '1':
                    MSSql.create_Table()  
                    
                elif option == '2':
                    MSSql.get_Tables()
                    table_name = input("Enter the name of the table to insert data into: ")
                    MSSql.insert_Into_Table(table_name)
                    
                elif option == '3':
                    MSSql.get_Tables()
                    table_name = input("Enter the name of the table you want to update: ")
                    MSSql.update_Table(table_name)
                    
                elif option == '4':
                    MSSql.get_Tables()
                    table_name = input("Enter the name of the table from which you want to delete a record: ")
                    MSSql.delete_Record_In_Table(table_name)
                    
                elif option == '5':
                    print("Exiting...")
                    break
                
                else:
                    print("Invalid option. Please try again.")
    else:
        print("Failed to connect to the database.")




if __name__ == "__main__":
    main()