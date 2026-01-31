import os
import sys


def get_and_check_paths():
    """
    Valida los argumentos de entrada y verifica si los archivos existen.
    """
    if len(sys.argv) < 3:  # +1 porque sys.argv[0] es el script
        print(
            f"Usage: {sys.argv[0]} {{database_file}} {{compressed_clinvar_file}}",
            file=sys.stderr
        )
        sys.exit(1)

    db_file = sys.argv[1]
    data_file = sys.argv[2]

    if os.path.exists(db_file):
        raise FileExistsError(
            f"El path de base de datos '{db_file}' ya existe.")

    if not os.path.exists(data_file):
        raise FileExistsError(f"El path del archivo '{data_file}' no existe.")

    return db_file, data_file


if __name__ == "__main__":
    try:
        db_file, clinvar_file = get_and_check_paths()
        print(f"Database file: {db_file}")
        print(f"ClinVar file: {clinvar_file}")
    except FileExistsError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
