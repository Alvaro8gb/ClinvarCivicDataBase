import sys
import sqlite3
import pandas as pd


CHR_DATA_BP = {
    'chro': ['1', '22', 'X'],
    'length_GRCh37': [249_250_621, 51_304_566, 1552_70_560],
    'length_GRCh38': [248_956_422, 50_818_468, 156_040_895]
}

QUERY = """
    SELECT 
        assembly, 
        chro, 
        COUNT(DISTINCT(variant_id)) AS n_variants
    FROM variant
    WHERE chro IN ('1', '22', 'X') 
    AND (assembly = 'GRCh37' OR assembly = 'GRCh38')
    GROUP BY assembly, chro;
"""



if __name__ == '__main__': 

    if len(sys.argv) < 2:
        print("Usage: {0} {{database_file}}".format(
            sys.argv[0]), file=sys.stderr)

        sys.exit(1)

    db_path = sys.argv[1]
    conn = sqlite3.connect(db_path)

    df_lengths = pd.DataFrame(CHR_DATA_BP)
    
    print("Chromosome length by assembly")
    print(df_lengths.to_markdown(index=False))

    
    df_freq_variantes = pd.read_sql_query(QUERY, conn)

    print("Variants per chro and assembly")
    print(df_freq_variantes.to_markdown(index=False))


    df_freq_with_lengths = df_freq_variantes.merge(df_lengths, on='chro')

    # Calculate mutation frequency (mutations per bp)
    df_freq_with_lengths['freq_GRCh37'] = df_freq_with_lengths.apply(
        lambda row: row['n_variants'] / row['length_GRCh37'] if row['assembly'] == 'GRCh37' else None, axis=1
    )

    df_freq_with_lengths['freq_GRCh38'] = df_freq_with_lengths.apply(
        lambda row: row['n_variants'] / row['length_GRCh38'] if row['assembly'] == 'GRCh38' else None, axis=1
    )

    df_freq_pivot = df_freq_with_lengths.pivot(
        index='chro', 
        columns='assembly', 
        values=['n_variants', 'freq_GRCh37', 'freq_GRCh38']
    )

    # Flatten the multi-level columns
    df_freq_pivot.columns = ['_'.join(col).strip() for col in df_freq_pivot.columns.values]

    # Rename columns for clarity
    df_freq_pivot = df_freq_pivot.rename(columns={
        'n_variants_GRCh37': 'Variants_GRCh37',
        'n_variants_GRCh38': 'Variants_GRCh38',
        'freq_GRCh37_GRCh37': 'Frequency_GRCh37',
        'freq_GRCh38_GRCh38': 'Frequency_GRCh38'
    })

    # Select only the relevant columns and reset index
    df_freq_pivot = df_freq_pivot[['Variants_GRCh37', 'Frequency_GRCh37', 'Variants_GRCh38', 'Frequency_GRCh38']].reset_index()
    df_freq_pivot.rename(columns={'chro': 'Chromosome'}, inplace=True)

    print("Frequency of mutations")

    print(df_freq_pivot.to_markdown(index=False))
