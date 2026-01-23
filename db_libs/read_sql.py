
def load_clinvar_table_defs(sql_file_path:str):
    with open(sql_file_path, "r", encoding="utf-8") as f:
        content = f.read()
    # Split statements by semicolon followed by a newline (handles multi-line statements)
    statements = [stmt.strip()
                  for stmt in content.split(";\n") if stmt.strip()]

    return statements