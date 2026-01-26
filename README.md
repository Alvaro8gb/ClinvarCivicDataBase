# ClinvarCivicDataBase


```bash
wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/archive/variant_summary_2025-01.txt.gz
wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/archive/gene_specific_summary_2025-01.txt.gz
wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/archive/submission_summary_2025-01.txt.gz


wget https://civicdb.org/downloads/nightly/nightly-VariantSummaries.tsv
```

```bash
python clinvar_variant_parser.py  ./dumps/clinvar_variant.db data/variant_summary_2025-01.txt.gz
```

```bash
python clinvar_gene_parser.py dumps/clinvar_gene.db data/gene_specific_summary_2025-01.txt.gz
```

## Clinvar


### Qué significa gene_id = -1 ?

Indica que la variante NO está asignada de forma inequívoca a un gen específico.

- Variante intergénica: Está entre genes, no dentro de uno conocido.

- Región reguladora o no codificante: Por ejemplo: upstream/downstream, intrones profundos, regiones promotoras sin asignación clara.
- Variante estructural o grande
- Deleciones/duplicaciones que abarcan varios genes o regiones amplias
- Información incompleta o ambigua en ClinVar

## Queries

### 1. ¿Cuántas variantes están relacionadas con el gen P53 tomando como referencia el ensamblaje GRCh38 en ClinVar y en CIViC?

```sql
SELECT 
	COUNT(DISTINCT(variation_id)),
	COUNT(variation_id), 
	COUNT(DISTINCT(allele_id)),
	COUNT(allele_id)
FROM variant
WHERE assembly = 'GRCh38';
```
3058778	3059494	3058778	3059494


```sql

SELECT 
	COUNT(variant_id)
FROM variant
WHERE 
	gene_symbol LIKE "%P53%" AND 
	assembly = 'GRCh38';

```



### 2. ¿Qué cambio del tipo “single nucleotide variant” es más frecuente, el de una Guanina por una Adenina, o el una Guanina por una Timina? Usad las anotaciones basadas en el ensamblaje GRCh37 para cuantificar y proporcionar los números totales, tanto para ClinVar como para CIViC.

#### Clinvar


```sql

SELECT 
	ref_allele,
	alt_allele,
	COUNT(variant_id) as n_variants
FROM variant
WHERE assembly = 'GRCh37' AND type = 'single nucleotide variant'
GROUP BY ref_allele, alt_allele
ORDER BY n_variants DESC;
```
|ref_allele|alt_allele|freq|
|----------|----------|----|
|C|T|615502|
|G|A|613361|
|A|G|305691|



#### Civic 

```sql

SELECT 
	ref_allele, 
	alt_allele, 
	COUNT(variant_id) as n_variants
FROM variant
WHERE
	assembly = 'GRCh37' AND
	variant_types LIKE "%SNP%" OR
	variant_types LIKE "%missense_variant%" OR 
	variant_types LIKE "%synonymous_variant%" OR 
	variant_types LIKE "%stop_gained%" OR
	variant_types LIKE "%stop_lost%" OR
	variant_types LIKE "%start_lost%"
GROUP BY ref_allele, alt_allele
ORDER BY n_variants DESC;

```

### 3. ¿Cuáles son los tres genes de ClinVar con un mayor número de inserciones, deleciones o indels? Usa el ensamblaje GRCh37 para cuantificar y proporcionar los números totales.

```sql

SELECT 
	gene_symbol,
	COUNT(*) as freq
FROM variant
WHERE assembly = 'GRCh37' AND 
	type IN (
      'Indel',
      'Insertion',
      'Deletion'
      )
GROUP BY gene_symbol
ORDER BY freq DESC;
```

|gene_symbol|freq|
|-----------|----|
|BRCA2|3524|
|BRCA1|2872|
|NF1|2567|


### 4. ¿Cuál es la deleción más común en el cáncer hereditario de mama en CIViC? ¿Y en ClinVar? Por favor, incluye en la respuesta además en qué genoma de referencia, el número de veces que ocurre, el alelo de referencia y el observado.

```sql

SELECT 
	v.variation_id,
	COUNT(*) AS freq,
	v.ref_allele, 
	v.alt_allele
FROM variant v
JOIN clinical_sig c ON v.ventry_id = c.ventry_id
WHERE 
	v.type = 'Deletion' AND
	v.assembly = 'GRCh37' AND 
	c.significance IN ('Pathogenic', 'Likely pathogenic')
GROUP BY v.variation_id, v.ref_allele, v.alt_allele
ORDER BY freq DESC;
```

falta añadir cancer hereditario de mama


### 5. Ver el identificador de gen y las coordenadas de las variantes de ClinVar del ensamblaje GRCh38 relacionadas con el fenotipo del Acute infantile liver failure due to synthesis defect of mtDNA-encoded proteins.

```sql
SELECT 
	variation_id,
	gene_id ,
	gene_symbol,
	chro,
	chro_start,
	chro_stop,
	phenotype_list 
FROM variant
WHERE 
	assembly = 'GRCh37' AND
	phenotype_list LIKE '%Acute infantile liver failure due to synthesis defect of mtDNA-encoded proteins%';

```
|variation_id|gene_id|gene_symbol|chro|chro_start|chro_stop|phenotype_list|
|------------|-------|-----------|----|----------|---------|--------------|
|1290|55687|TRMU|22|46335792|46335792|Deafness, mitochondrial, modifier of&#124;not specified&#124;Acute infantile liver failure due to synthesis defect of mtDNA-encoded proteins&#124;not provided&#124;Acute infantile liver failure due to synthesis defect of mtDNA-encoded proteins;Aminoglycoside-induced deafness|
|1291|55687|TRMU|22|46337925|46337925|Acute infantile liver failure due to synthesis defect of mtDNA-encoded proteins&#124;not provided&#124;Aminoglycoside-induced deafness&#124;TRMU-related disorder|
|1293|55687|TRMU|22|46353809|46353809|Acute infantile liver failure due to synthesis defect of mtDNA-encoded proteins|



### 6. Para aquellas variantes de ClinVar con significancia clínica “Pathogenic” o “Likely pathogenic”, recuperar las coordenadas, el alelo de referencia y el alelo alterado para la hemoglobina (HBB) en el assembly GRCh37.

```sql
SELECT 
	v.variation_id,
	c.significance,
	v.gene_id ,
	v.gene_symbol,
	v.chro,
	v.chro_start,
	v.chro_stop
FROM variant v
JOIN clinical_sig c ON v.ventry_id = c.ventry_id
WHERE
	c.significance IN ('Pathogenic', 'Likely pathogenic') AND
	v.assembly = 'GRCh37' AND
	v.gene_symbol ='HBB';
```



### 7. Calcular el número de variantes del ensamblaje GRCh37 que se encuentren en el cromosoma 13, entre las coordenadas 10,000,000 y 20,000,000 , tanto para ClinVar como para CIViC.

```sql

SELECT 
	COUNT(DISTINCT(variation_id)), 
	COUNT(*)
FROM variant
WHERE
	assembly = 'GRCh37' AND 
	chro = 13 AND
	chro_start >= 1000000 AND 
	chro_stop <= 20000000;
```


### 8. Calcular el número de variantes de ClinVar para los cuáles se haya provisto entradas de significancia clínica que no sean inciertas (“Uncertain significance”), del ensamblaje GRCh38, en aquellas variantes relacionadas con BRCA2.

```sql

SELECT 
	COUNT(DISTINCT(v.variation_id)) as n_variants
FROM variant v
JOIN clinical_sig c ON v.ventry_id = c.ventry_id
WHERE
	c.significance = 'Uncertain significance' AND
	v.assembly = 'GRCh38' AND
	v.gene_symbol ='BRCA2';

```



### 9. Obtener el listado de pubmed_ids de ClinVar relacionados con las variantes del ensamblaje GRCh38 relacionadas con el fenotipo del glioblastoma.

```sql

ATTACH DATABASE 'clinvar_variant.db' as variants;


SELECT 
    v.ventry_id,
    v.variation_id,
    s.submission_id,
    p.pmid, 
    v.phenotype_list
FROM variants.variant v
JOIN clinvar_submission s 
    ON v.variation_id = s.variation_id 
 JOIN variant_pmid p
    ON s.submission_id = p.submission_id 
WHERE 
	v.assembly = 'GRCh38' AND 
	v.phenotype_list LIKE '%glioblastoma%'; 

```

```sql

SELECT 
	v.ventry_id,
    v.variation_id,
    s.submission_id,
    p.pmid, 
    v.phenotype_list
FROM (
    SELECT * FROM variants.variant 
    WHERE assembly = 'GRCh38' AND 
    phenotype_list LIKE '%glioblastoma%'
    LIMIT 100
) v
JOIN clinvar_submission s ON v.variation_id = s.variation_id 
JOIN variant_pmid p ON s.submission_id = p.submission_id

```

### 10. Obtener el número de variantes del cromosoma 1 y calcular la frecuencia de mutaciones de este cromosoma, tanto para GRCh37 como para GRCh38. ¿Es esta frecuencia mayor que la del cromosoma 22? ¿Y si lo comparamos con el cromosoma X? 

Tomad para los cálculos los tamaños cromosómicos disponibles tanto en https://www.ncbi.nlm.nih.gov/grc/human/data?asm=GRCh37.p13 como en https://www.ncbi.nlm.nih.gov/grc/human/data?asm=GRCh38.p13 . 
Para esta pregunta se debe usar solo los datos proporcionados por ClinVar.

| Cromosoma | Longitud GRCh37 (bp) | Longitud GRCh38 (bp) |
|----------|----------------------|----------------------|
| 1        | 249,250,621          | 248,956,422          |
| 22       | 51,304,566           | 50,818,468           |
| X        | 155,270,560          | 156,040,895          |


Dado que frecuencia de mutaciones es 

$$\text{Frecuencia} = \frac{\text{Número de Variantes}}{\text{Tamaño del Cromosoma (bp)}}$$


Same query for both

```sql
SELECT 
    assembly, 
    chro, 
    COUNT(DISTINCT(variant_id)) AS n_variants
FROM variant
WHERE chro IN ('1', '22', 'X') 
  AND (assembly = 'GRCh37' OR assembly = 'GRCh38')
GROUP BY assembly, chro;
```

#### Clinvar

```bash
python freq_variants.py dumps/clinvar_variant.db 

```

Variants per chro and assembly
| assembly   | chro   |   n_variants |
|:-----------|:-------|-------------:|
| GRCh37     | 1      |       273635 |
| GRCh37     | 22     |        68638 |
| GRCh37     | X      |       121626 |
| GRCh38     | 1      |       269954 |
| GRCh38     | 22     |        67166 |
| GRCh38     | X      |       116860 |
Frequency of mutations
| Chromosome   |   Variants_GRCh37 |   Frequency_GRCh37 |   Variants_GRCh38 |   Frequency_GRCh38 |
|:-------------|------------------:|-------------------:|------------------:|-------------------:|
| 1            |            273635 |        0.00109783  |            269954 |        0.00108434  |
| 22           |             68638 |        0.00133785  |             67166 |        0.00132168  |
| X            |            121626 |        0.000783317 |            116860 |        0.000748906 |

### Civic

```bash
python freq_variants.py dumps/civiv_variant.db
```

Variants per chro and assembly
| assembly   | chro   |   n_variants |
|:-----------|:-------|-------------:|
| GRCh37     | 1      |           58 |
| GRCh37     | 22     |           14 |
| GRCh37     | X      |           22 |
| GRCh38     | 1      |            1 |
Frequency of mutations
| Chromosome   |   Variants_GRCh37 |   Frequency_GRCh37 |   Variants_GRCh38 |   Frequency_GRCh38 |
|:-------------|------------------:|-------------------:|------------------:|-------------------:|
| 1            |                58 |        2.32698e-07 |                 1 |        4.01677e-09 |
| 22           |                14 |        2.7288e-07  |               nan |      nan           |
| X            |                22 |        1.41688e-07 |               nan |      nan           |