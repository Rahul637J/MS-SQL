'''

@Author: Rahul 
@Date: 2024-09-13
@Last Modified by: Rahul 
@Last Modified time: 2024-09-13
@Title: Employee wages - Python program to demonstrate crud operation in ms sql.  

'''

import pyodbc as db

class MSSql:
    
    @staticmethod
    def create_Connection():
        
        """
        Description:
            The function to create connection with the database.
        Parameters:
            None.
        Return Type:
            connection.cursor() (Cursor) - Returns the cursor class object.
        """
        
        connection_str=(
                 "Driver={ODBC Driver 17 for SQL Server};"
                 "Server=GURUNADHA\\SQLExpress;"
                 "Database=demo;"
                 "Trusted_Connection=yes;"
                 ) 
        connection = db.connect(connection_str)
        return connection.cursor()
    
    @staticmethod    
    def create_Table():
        cursor=MSSql.create_Connection()
        
        table_name = input("Enter the Table name to create: ")
        
        columns = []
        primary_key_columns = []
        num_columns = int(input("Enter the number of columns: "))
        
        for i in range(num_columns):
            column_name = input(f"Enter the name of column {i+1}: ")
            data_type = input(f"Enter the data type for {column_name} (e.g., INT, VARCHAR(100)): ")
            
            not_null = input(f"Should {column_name} be NOT NULL? (yes/no): ").lower()
            constraint = "NOT NULL" if not_null == 'yes' else ""
            
            primary_key = input(f"Should {column_name} be a PRIMARY KEY? (yes/no): ").lower()
            if primary_key == 'yes':
                primary_key_columns.append(column_name)
            
            columns.append(f"{column_name} {data_type} {constraint}")
        
        column_definitions = ", ".join(columns)
        
        if primary_key_columns:
            primary_key_definition = f", PRIMARY KEY ({', '.join(primary_key_columns)})"
            column_definitions += primary_key_definition
        
        create_table_sql = f"CREATE TABLE {table_name} ({column_definitions});"
        
        try:
            cursor.execute(create_table_sql)
            cursor.commit()
            print(f"Table '{table_name}' created successfully.")
        except Exception as e:
            print(f"Error creating table: {e}")
        finally:
            cursor.close()
    
    @staticmethod
    def insert_Into_Table():
        pass
    
    @staticmethod
    def update_Table():
        pass
        
    @staticmethod
    def delete_Record_In_Table():
        pass    
            
def main():
    print("-"*45+"\n| CRUD Operation in MS Sql server by python |\n"+"-"*45)
    
    while True:
        option=int(input("Enter \n"+
                         "1. To create table\n"+
                         "2. To insert values in table\n"+
                         "3. To update into table\n"+
                         "4. To delete record in the tbale "
                         "option: "))
        
        if option == 1:
            MSSql.create_Table()

if __name__ == "__main__":
    main()