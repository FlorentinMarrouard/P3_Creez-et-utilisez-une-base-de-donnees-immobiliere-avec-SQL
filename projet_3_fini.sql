#1. Nombre total d’appartements vendus au 1er semestre 2020.
SELECT 
	count(*) as "vente appartement 1er sem 2020"
FROM table_vente as v
	INNER JOIN table_bien as b on v.id_bien = b.id_bien
WHERE
	DATE between "2020-01-01" and "2020-06-30"
    and b.Type_local = "Appartement"; 
    
#2. Le nombre de ventes d’appartement par région pour le 1er semestre 2020.

SELECT table_commune.id_Region, table_region.Nom_Reg, count(DISTINCT table_bien.id_bien) AS "Nbre de vente 
d’appart"
FROM table_bien
JOIN table_vente ON table_bien.id_bien = table_vente.id_bien
JOIN table_commune on table_bien.id_code_dep_code_commune = table_commune.id_code_dep_code_commune
JOIN table_region on table_commune.id_Region = table_region.id_Region
where Type_local= 'Appartement' and date BETWEEN "2020-01-01" and "2020-06-30"
GROUP BY table_commune.id_Region
ORDER by "Nbre de vente d’appart" DESC;

# 3. Proportion des ventes d’appartements par le nombre de pièces.
#voir cours sous-select 
SELECT Total_pieces AS "Nombre de pièces", round(count(id_vente) /
(SELECT round(count(id_vente),2)
FROM table_vente JOIN table_bien USING (id_bien)
WHERE Type_local = 'Appartement')*100,2) AS "Proportion de ventes
d'appartements"
FROM table_vente
JOIN table_bien USING (id_bien)
WHERE Type_local = 'Appartement'
GROUP BY Total_pieces
ORDER BY Total_pieces;

# 4.Liste des 10 départements où le prix du mètre carré est le plus élevé
SELECT code_departement AS "Département",
round(avg(Valeur / surface_carrez),2) AS "Prix au mètre carré"
FROM table_vente
JOIN table_bien USING (id_bien)
JOIN table_commune USING (id_code_dep_code_commune)
WHERE surface_carrez != 0 AND code_departement IS NOT NULL
GROUP BY Département
ORDER BY round(avg(Valeur / surface_carrez),2) DESC
LIMIT 10;
 
#5. Prix moyen du mètre carré d’une maison en Île-de-France.
SELECT round(avg(valeur / surface_carrez),2) AS "Prix maison au m² en IDF"
FROM table_bien
JOIN table_vente ON table_bien.id_bien = table_vente.id_bien
JOIN table_commune on table_bien.id_code_dep_code_commune = table_commune.id_code_dep_code_commune
JOIN table_region on table_commune.id_Region = table_region.id_Region
WHERE Nom_Reg = "Ile-de-France"
AND Type_local = 'Maison';


# 6 Liste des 10 appartements les plus chers avec la région et le nombre de mètres carrés.
SELECT table_bien.id_bien, round(Valeur,0) AS "Prix", Nom_Reg, code_departement AS "Département", 
round(surface_carrez,0) AS "Surface"
FROM table_bien
JOIN table_vente ON table_bien.id_bien = table_vente.id_bien
JOIN table_commune on table_bien.id_code_dep_code_commune = table_commune.id_code_dep_code_commune
JOIN table_region on table_commune.id_Region = table_region.id_Region
WHERE Type_local = 'Appartement' AND valeur != 0
ORDER BY round(valeur,0) DESC
LIMIT 10;


# 7. Taux d’évolution du nombre de ventes entre le premier et le second trimestre de 2020.
WITH
vente1 AS (
 SELECT round(count(id_vente),2) AS nbventes1
 FROM table_vente
 WHERE date BETWEEN "2020-01-01" AND "2020-03-31"),
vente2 AS (
 SELECT round(count(id_vente),2) AS nbventes2
 FROM table_vente
 WHERE date BETWEEN "2020-04-01" AND "2020-06-30")
SELECT round(((nbventes2 - nbventes1) / nbventes1 * 100), 2) AS "Taux d'évolution"
FROM vente1, vente2;

#8. Le classement des régions par rapport au prix au mètre carré des appartements de plus de 4 pièces.

SELECT Nom_Reg AS "Nom_Reg",
round(avg(Valeur / surface_carrez),0) AS "Prix au mètre carré"
FROM table_region
JOIN table_commune USING (id_Region)
JOIN table_bien USING (id_code_dep_code_commune)
JOIN table_vente USING (id_bien)
WHERE Type_local = "Appartement" AND Total_pieces >4 
GROUP BY Nom_Reg
ORDER BY round(avg(Valeur / surface_carrez),0) DESC
LIMIT 20;


#9. Liste des communes ayant eu au moins 50 ventes au 1er trimestre
SELECT table_commune.Nom_commune as "Nom_commune",
count(id_vente) as "Nombre de ventes" 
FROM table_vente 
JOIN table_bien ON table_vente.id_bien = table_bien.id_bien
JOIN table_commune on table_bien.id_code_dep_code_commune = table_commune.id_code_dep_code_commune
WHERE
	DATE between "2020-01-01" AND "2020-04-01"
GROUP BY table_commune.Nom_commune
HAVING count(table_vente.id_vente) >= 50
ORDER BY ("Nombre de ventes" >50);

#10. Différence en pourcentage du prix au mètre carré entre un appartement de 2 pièces et un appartement de 3 pièces.
WITH
prix_2pc AS (
 SELECT round(avg(Valeur / surface_carrez),0) AS prix_2pc
 FROM table_vente
 JOIN table_bien USING (id_bien)
 WHERE Type_local = "Appartement" AND Total_pieces = 2 ),
prix_3pc AS (
 SELECT round(avg(Valeur / surface_carrez),0) AS prix_3pc
 FROM table_vente
 JOIN table_bien USING (id_bien)
 WHERE Type_local = "Appartement" AND Total_pieces = 3)

SELECT round(((prix_3pc - prix_2pc) / prix_2pc * 100), 2) AS "Différence en pourcentage du prix au mètre carré entre un appartement de 2 pièces et un appartement de 3 pièces"
FROM prix_2pc, prix_3pc;


#11. Les moyennes de valeurs foncières pour le top 3 des communes des départements 6, 13, 33, 59 et 69.
   
WITH valeur_fonc_moy_ville AS (SELECT code_departement, Nom_commune, round(avg(Valeur),2) AS val_fonc_moy
FROM table_bien
JOIN table_commune USING (id_code_dep_code_commune) 
JOIN table_vente USING(id_bien) 
WHERE code_departement in ("6","13","33","59","69")
GROUP BY table_commune.id_code_dep_code_commune)

SELECT * FROM (SELECT code_departement, Nom_commune, val_fonc_moy,
RANK() OVER (PARTITION BY code_departement ORDER BY (val_fonc_moy) DESC) as RANG
FROM valeur_fonc_moy_ville
ORDER BY code_departement ASC, RANG ASC, Nom_commune ASC) as result 
WHERE result.rang <=3;



#12. Les 20 communes avec le plus de transactions pour 1000 habitants pour les communes qui dépassent les 10 000 habitants.

WITH transac_ville AS (
  SELECT code_departement, Nom_commune,Nb_hab_total, (count(id_vente)/(Nb_hab_total/1000)) AS nb_transac_1000hab_ville
  FROM table_bien
  JOIN table_commune USING (id_code_dep_code_commune) 
  JOIN table_vente USING(id_bien) 
  WHERE Nb_hab_total > 10000
  GROUP BY code_departement, Nom_commune,Nb_hab_total
)
SELECT code_departement, Nom_commune, nb_transac_1000hab_ville, rang
FROM (
SELECT code_departement, Nom_commune, nb_transac_1000hab_ville,
RANK() OVER (ORDER BY nb_transac_1000hab_ville DESC) AS rang
  FROM transac_ville
) AS resultat
WHERE rang <= 25
ORDER BY nb_transac_1000hab_ville DESC
LIMIT 20;




