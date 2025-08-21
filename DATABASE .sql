
CREATE DATABASE RNC
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'French_France.1252'
    LC_CTYPE = 'French_France.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
-- \C RNC (invite cmnd)

 CREATE TABLE Projet (
    id SERIAL PRIMARY KEY
);

CREATE TABLE FicheTechnique (
    id SERIAL PRIMARY KEY,
    projet_id INT,
    name TEXT,
    type TEXT,
    bassin TEXT,
    formation TEXT,
    profondeur DOUBLE PRECISION,
    plateau DOUBLE PRECISION,
    FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE
);

CREATE TABLE PhaseRecherche (
    id SERIAL PRIMARY KEY,
    fiche_technique_id INT NOT NULL,
    nbr_puits_exploration INT,
    nbr_puits_appreciation INT,
    nbr_stage_exploration INT,
    nbr_stage_appreciation INT,
    longeur_tubage DOUBLE PRECISION,
    longeur_drain DOUBLE PRECISION,
    td DOUBLE PRECISION,
    FOREIGN KEY (fiche_technique_id) REFERENCES FicheTechnique(id) ON DELETE CASCADE
);

CREATE TABLE RechercheSupplyChaine (
    id SERIAL PRIMARY KEY,
    id_recherche INT,
    quantity_boue DOUBLE PRECISION,
    cout_boue DOUBLE PRECISION,
    cout_unite_boue DOUBLE PRECISION,

    quantity_eau DOUBLE PRECISION,
    cout_eau DOUBLE PRECISION,
    cout_unite_eau DOUBLE PRECISION,

    quantity_propant DOUBLE PRECISION,
    cout_propant DOUBLE PRECISION,
    cout_unite_propant DOUBLE PRECISION,

    quantity_ciment DOUBLE PRECISION,
    cout_ciment DOUBLE PRECISION,
    cout_unite_ciment DOUBLE PRECISION,

    quantity_tubage DOUBLE PRECISION,
    cout_tubage DOUBLE PRECISION,
    cout_unite_tubage DOUBLE PRECISION,

    cout_supply_chaine DOUBLE PRECISION,

    FOREIGN KEY (id_recherche) REFERENCES PhaseRecherche(id) ON DELETE CASCADE
);

CREATE TABLE RechercheCouts (
    id SERIAL PRIMARY KEY,
    id_recherche INT,
    cout_puits_vertical DOUBLE PRECISION,
    cout_puits_horizontal DOUBLE PRECISION,
    cout_etude DOUBLE PRECISION,
    cout_sismique DOUBLE PRECISION,
    well_capex DOUBLE PRECISION,
    cout_total DOUBLE PRECISION,
    FOREIGN KEY (id_recherche) REFERENCES PhaseRecherche(id) ON DELETE CASCADE
);


-- Create the pilot table

CREATE TABLE pilot (
    id SERIAL PRIMARY KEY,
    nombre_pad INTEGER,
    nombre_puits_par_pad INTEGER,
    nombre_stage_frac_par_puits INTEGER,
    longueur_drain_m DECIMAL(10, 2),
    td_m DECIMAL(10, 2),
    longueur_tubage_m DECIMAL(10, 2)
);


CREATE TABLE supply_chain (
    id SERIAL PRIMARY KEY,
    pilot_id INTEGER NOT NULL REFERENCES pilot(id) ON DELETE CASCADE,
   
    -- Produits de boue
    quantite_boue_tonnes DECIMAL(10, 2) DEFAULT 0.0,
    cout_par_tonne_boue DECIMAL(10, 2),
    cout_boue DECIMAL(10, 2),
    
    -- Tubage
    quantite_tubage_tonnes DECIMAL(10, 2) DEFAULT 0.0,
    cout_par_tonne_tubage DECIMAL(10, 2),
    cout_tubage DECIMAL(10, 2),
    
    -- Ciment et additifs
    quantite_ciment_tonnes DECIMAL(10, 2) DEFAULT 0.0,
    cout_par_tonne_ciment DECIMAL(10, 2),
    cout_ciment DECIMAL(10, 2),
    
    -- Separateur
    nombre_separateur INTEGER,
    cout_par_separateur DECIMAL(10, 2),
    cout_separateur DECIMAL(10, 2),
    
    -- Proppant
    quantite_proppant_tonnes_par_stage DECIMAL(10, 2) DEFAULT 0.0,
    cout_par_tonne_proppant DECIMAL(10, 2),
    cout_proppant DECIMAL(10, 2),
    
    -- Manifold
    quantite_manifold INTEGER,
    cout_par_manifold DECIMAL(10, 2),
    cout_manifold DECIMAL(10, 2),
    
    -- Eau
    quantite_eau_m3_par_stage DECIMAL(10, 2) DEFAULT 0.0,
    cout_par_m3_eau DECIMAL(10, 2),
    cout_eau DECIMAL(10, 2),
    
    -- Cout total 
    cout_total_supply_chain DECIMAL(10, 2)
);

ALTER TABLE pilot ADD COLUMN projet_id INTEGER;
ALTER TABLE pilot 
ADD CONSTRAINT fk_pilot_projet 
FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE;
ALTER TABLE supply_chain ADD COLUMN projet_id INTEGER;
ALTER TABLE supply_chain 
ADD CONSTRAINT fk_supply_chain_projet 
FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE;

-- phase devloppement

CREATE TABLE PhaseDeveloppement (
    id SERIAL PRIMARY KEY,
    projet_id INTEGER NOT NULL REFERENCES Projet(id) ON DELETE CASCADE,
    gaz_densite_bcf_km2 DECIMAL(10,2) NOT NULL,
    longueur_drain_km DECIMAL(10,2) NOT NULL,
    d_longueur_fraction_hydraulique_km DECIMAL(10,2) NOT NULL,
    production_initiale_mille_m3_mois DECIMAL(12,2) NOT NULL,
    plateau_production_bcm_an DECIMAL(10,2) NOT NULL
);
CREATE TABLE supply_chaine (
    id SERIAL PRIMARY KEY,
    projet_id INTEGER NOT NULL REFERENCES Projet(id) ON DELETE CASCADE,
    phase_developpement_id INTEGER NOT NULL REFERENCES PhaseDeveloppement(id) ON DELETE CASCADE,
    jours_par_puits INTEGER NOT NULL,
    puits_par_pad INTEGER NOT NULL,
    degressivite_an_pourcent DECIMAL(5,2) NOT NULL,
    stages_par_frac INTEGER NOT NULL,
    capacite_mpf DECIMAL(5,2) NOT NULL,
    pipe_km DECIMAL(10,2) NOT NULL,
    td_metres DECIMAL(10,2) NOT NULL,
    longueur_tubage_metres DECIMAL(10,2) NOT NULL
);




CREATE TABLE RecoveryFactors (
    id SERIAL PRIMARY KEY,
    phase_developpement_id INTEGER NOT NULL REFERENCES PhaseDeveloppement(id) ON DELETE CASCADE,
    type VARCHAR(10) NOT NULL CHECK (type IN ('P90', 'P50', 'P10')),
    valeur DECIMAL(5,2) NOT NULL,
    b DECIMAL(5,2) NOT NULL,
    d DECIMAL(5,2) NOT NULL,
    ds DECIMAL(5,2) NOT NULL
);

create table production_annuelle (annee_id int primary key , description varchar(255),
projet_id int,
pod10 NUMERIC(15, 2),
pod50 NUMERIC(15, 2),
pod90 NUMERIC(15, 2),
    FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
     FOREIGN KEY (recoveryfactory_id) REFERENCES RecoveryFactors ON DELETE CASCADE,
	date_mise_ajour timestamp default current_timestamp );
	with annees as (
		select generate_series(1,30)as annee
	)
insert into  production_annuelle(annee_id ) select annee from annees;

create table planning_forage (annee_id int primary key , description varchar(255),
projet_id int,
pod10 NUMERIC(15, 2),
pod50 NUMERIC(15, 2),
pod90 NUMERIC(15, 2),
    FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
     FOREIGN KEY (recoveryfactory_id) REFERENCES RecoveryFactors ON DELETE CASCADE,
	date_mise_ajour timestamp default current_timestamp );
	with annees as (
		select generate_series(1,30)as annee
	)
insert into  planning_forage (annee_id ) select annee from annees;



CREATE TABLE eur(
    id SERIAL PRIMARY KEY,
    projet_id int,
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
          FOREIGN KEY (recoveryfactory_id) REFERENCES RecoveryFactors ON DELETE CASCADE,
    percentile VARCHAR(3) CHECK (percentile IN ('p10', 'p50', 'p90')),
    eur_technique DECIMAL(15,2) DEFAULT 0.0,
    eur_smule DECIMAL(15,2) DEFAULT 0.0
);

CREATE TABLE total_de_puits (
    id SERIAL PRIMARY KEY,
    projet_id INT,
       FOREIGN KEY (recoveryfactory_id) REFERENCES RecoveryFactors ON DELETE CASCADE,
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
    p10 DECIMAL(15 , 2 ) DEFAULT 0.0,
    p50 DECIMAL(15 , 2 ) DEFAULT 0.0,
    p90 DECIMAL(15 , 2 ) DEFAULT 0.0
);


CREATE TABLE Capex (
    id SERIAL PRIMARY KEY,
     supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine (id) ON DELETE CASCADE,
    projet_id INTEGER NOT NULL REFERENCES Projet(id) ON DELETE CASCADE,
     phase_developpement_id INTEGER NOT NULL REFERENCES PhaseDeveloppement(id) ON DELETE CASCADE,
    etude_sismique_usd_m DECIMAL(12,2) NOT NULL,
    cout_forage_premier_puit_usd_m DECIMAL(12,2) NOT NULL,
    cout_frac_par_stage_usd_m DECIMAL(12,2) NOT NULL,
    cout_manifold_unitaire_usd_m DECIMAL(12,2) NOT NULL,
    cout_manifold_rassemblement_usd_m DECIMAL(12,2) NOT NULL,
    cout_compresseur_unitaire_usd_m DECIMAL(12,2) NOT NULL,
    cout_mpf_unite_usd_m DECIMAL(12,2) NOT NULL,
    cout_pipe_par_km_usd_m DECIMAL(12,2) NOT NULL
);


CREATE TABLE Apex (
    id SERIAL PRIMARY KEY,
     supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine (id) ON DELETE CASCADE,
     phase_developpement_id INTEGER NOT NULL REFERENCES PhaseDeveloppement(id) ON DELETE CASCADE,
    projet_id INTEGER NOT NULL REFERENCES Projet(id) ON DELETE CASCADE,
    pourcentage_capex DECIMAL(5,2) NOT NULL
);


CREATE TABLE Opex (
    id SERIAL PRIMARY KEY,
     supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine (id) ON DELETE CASCADE,
    projet_id INTEGER NOT NULL REFERENCES Projet(id) ON DELETE CASCADE,
     phase_developpement_id INTEGER NOT NULL REFERENCES PhaseDeveloppement(id) ON DELETE CASCADE,
    flow_back_pourcent DECIMAL(5,2) NOT NULL,
    cout_traitement_eau_usd_m3 DECIMAL(10,2) NOT NULL,
    main_doeuvre_directe_usd_puit DECIMAL(12,2) NOT NULL,
    charge_compression_usd_puit DECIMAL(12,2) NOT NULL,
    workover_frac_par_puit DECIMAL(5,2) NOT NULL,
    rate_per_volume_unit_usd_bcm DECIMAL(12,2) NOT NULL
);




create table etude_echonomiquep10(annee_id int primary key , revenusM decimal(12,5),
	cash_flow decimal(12,5),projet_id int,
    phase_developpement_id INTEGER NOT NULL REFERENCES PhaseDeveloppement(id) ON DELETE CASCADE,
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
	date_mise_ajour timestamp default current_timestamp );
	with annees as (
		select generate_series(1,30)as annee
	)
insert into etude_echonomiquep10(annee_id ) select annee from annees;



create table etude_echonomiquep50(annee_id int primary key , revenusM decimal(12,5),
	cash_flow decimal(12,5),
    phase_developpement_id INTEGER NOT NULL REFERENCES PhaseDeveloppement(id) ON DELETE CASCADE,
    projet_id int,
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
	date_mise_ajour timestamp default current_timestamp );
	with annees as (
		select generate_series(1,30)as annee
	)
insert into etude_echonomiquep50(annee_id ) select annee from annees;



create table etude_echonomiquep90(annee_id int primary key , revenusM decimal(12,5),
	cash_flow decimal(12,5),
    phase_developpement_id INTEGER NOT NULL REFERENCES PhaseDeveloppement(id) ON DELETE CASCADE,
    projet_id int,
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
	date_mise_ajour timestamp default current_timestamp );
	with annees as (
		select generate_series(1,30)as annee
	)
insert into etude_echonomiquep90(annee_id ) select annee from annees;



-- Table for unit price (Prix Unitaire)
CREATE TABLE unit_price (
phase_developpement_id INTEGER NOT NULL REFERENCES PhaseDeveloppement(id) ON DELETE CASCADE,
    id SERIAL PRIMARY KEY,
    projet_id int,
    price_value NUMERIC(10, 2) NOT NULL,  -- Price in $/MMBtu
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE
);

-- Table for Net Present Value (VAN) and Internal Rate of Return (TRI)
CREATE TABLE financial_metrics (
projet_id int,
    id SERIAL PRIMARY KEY,
    scenario VARCHAR(10) NOT NULL CHECK (scenario IN ('P90', 'P50', 'P10')),
    van NUMERIC(15, 2),  -- Net Present Value (Valeur Actuelle Nette)
    tri NUMERIC(5, 2),   -- Internal Rate of Return (Taux de Rentabilité Interne) in percentage
    calculation_date DATE DEFAULT CURRENT_DATE,
    notes TEXT,
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
    CONSTRAINT unique_scenario UNIQUE (scenario)
);

-- Table for Revenue and Cash Flow
CREATE TABLE revenue_cashflow (
    id SERIAL PRIMARY KEY,
    phase_developpement_id INTEGER NOT NULL REFERENCES PhaseDeveloppement(id) ON DELETE CASCADE,
    projet_id int,
    scenario VARCHAR(10) NOT NULL CHECK (scenario IN ('P90', 'P50', 'P10')),
    revenue_ms NUMERIC(15, 2),  -- Revenue in millions
    cashflow_ms NUMERIC(15, 2), -- Cash Flow in millions
    
    calculation_date DATE DEFAULT CURRENT_DATE,
    notes TEXT,
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
    CONSTRAINT unique_scenario_revenue UNIQUE (scenario)
);







-- scenariop10
CREATE TABLE scenarion_p10(
    annee_id integer PRIMARY KEY,
     supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine (id) ON DELETE CASCADE,
    projet_id int,
    nombre_rig numeric(12,5),
    boue numeric(12,5),
    tubage numeric(12,5),
    ciment numeric(12,5),
    eau numeric(12,5),
    propant numeric(12,5),
    nombre_pad numeric(12,5),
    manifod numeric(12,5),
    manfd_ressemblement numeric(12,5),
    nombre_compresseur numeric(12,5),
    nombre_mpf numeric(12,5),
    pipe numeric(12,5),
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
    date_mise_ajour timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Then populate it with years from 1 to 30
INSERT INTO scenarion_p10 (annee_id)
SELECT generate_series(1, 30) AS annee_id;
-- scenario p50
CREATE TABLE scenarion_p50(
 supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine (id) ON DELETE CASCADE,
    annee_id integer PRIMARY KEY,
    projet_id int,
    nombre_rig numeric(12,5),
    boue numeric(12,5),
    tubage numeric(12,5),
    ciment numeric(12,5),
    eau numeric(12,5),
    propant numeric(12,5),
    nombre_pad numeric(12,5),
    manifod numeric(12,5),
    manfd_ressemblement numeric(12,5),
    nombre_compresseur numeric(12,5),
    nombre_mpf numeric(12,5),
    pipe numeric(12,5),
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
    date_mise_ajour timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Then populate it with years from 1 to 30
INSERT INTO scenarion_p50 (annee_id)
SELECT generate_series(1, 30) AS annee_id;

-- scenario _p90
CREATE TABLE scenarion_p90(
 supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine (id) ON DELETE CASCADE,
    annee_id integer PRIMARY KEY,
    projet_id int,
    nombre_rig numeric(12,5),
    boue numeric(12,5),
    tubage numeric(12,5),
    ciment numeric(12,5),
    eau numeric(12,5),
    propant numeric(12,5),
    nombre_pad numeric(12,5),
    manifod numeric(12,5),
    manfd_ressemblement numeric(12,5),
    nombre_compresseur numeric(12,5),
    nombre_mpf numeric(12,5),
    pipe numeric(12,5),
        FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
    date_mise_ajour timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Then populate it with years from 1 to 30
INSERT INTO scenarion_p90 (annee_id)
SELECT generate_series(1, 30) AS annee_id;



CREATE TABLE couts_scenarion_p90(
    annee_id integer PRIMARY KEY,
     supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine (id) ON DELETE CASCADE,
    projet_id int,
    forage numeric(12,5),
   frac numeric(12,5),
    manifod numeric(12,5),
    manifod_rassemblement  numeric(12,5),
    compresseur  numeric(12,5),
   mpf numeric(12,5),
    pip numeric(12,5),
    capex_ms numeric(12,5),
    abex_ms numeric(12,5),
    lease_operating_expense numeric(12,5),
  gathening numeric(12,5),
 workover_cost  numeric(12,5),
opes_ms numeric(12,5),
  total_ms numeric(12,5),
      FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
    date_mise_ajour timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);-- Then populate it with years from 1 to 30
INSERT INTO couts_scenarion_p90 (annee_id)
SELECT generate_series(1, 30) AS annee_id;




-- p50
CREATE TABLE couts_scenarion_p50(
     capex_id INTEGER NOT NULL REFERENCES Capex (id) ON DELETE CASCADE,
     apex_id INTEGER NOT NULL REFERENCES Aapex (id) ON DELETE CASCADE,
     opex_id INTEGER NOT NULL REFERENCES Opex (id) ON DELETE CASCADE,
    annee_id integer PRIMARY KEY,
     supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine(id) ON DELETE CASCADE,
    projet_id int,
    forage numeric(12,5),
   frac numeric(12,5),
    manifod numeric(12,5),
    manifod_rassemblement  numeric(12,5),
    compresseur  numeric(12,5),
   mpf numeric(12,5),
    pip numeric(12,5),
    capex_ms numeric(12,5),
    abex_ms numeric(12,5),
    lease_operating_expense numeric(12,5),
  gathening numeric(12,5),
 workover_cost  numeric(12,5),
opes_ms numeric(12,5),
  total_ms numeric(12,5),
      FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
    date_mise_ajour timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);-- Then populate it with years from 1 to 30
INSERT INTO couts_scenarion_p50 (annee_id)
SELECT generate_series(1, 30) AS annee_id;




CREATE TABLE couts_scenarion_p10(
     capex_id INTEGER NOT NULL REFERENCES Capex (id) ON DELETE CASCADE,
     apex_id INTEGER NOT NULL REFERENCES Aapex (id) ON DELETE CASCADE,
     opex_id INTEGER NOT NULL REFERENCES Opex (id) ON DELETE CASCADE,
    annee_id integer PRIMARY KEY,
     supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine (id) ON DELETE CASCADE,
    projet_id int,
    forage numeric(12,5),
   frac numeric(12,5),
    manifod numeric(12,5),
    manifod_rassemblement  numeric(12,5),
    compresseur  numeric(12,5),
   mpf numeric(12,5),
    pip numeric(12,5),
    capex_ms numeric(12,5),
    abex_ms numeric(12,5),
    lease_operating_expense numeric(12,5),
  gathening numeric(12,5),
 workover_cost  numeric(12,5),
opes_ms numeric(12,5),
  total_ms numeric(12,5),
      FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE,
    date_mise_ajour timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);-- Then populate it with years from 1 to 30
INSERT INTO couts_scenarion_p10 (annee_id)
SELECT generate_series(1, 30) AS annee_id;



CREATE TABLE total_de_couts_p90 (
     capex_id INTEGER NOT NULL REFERENCES Capex (id) ON DELETE CASCADE,
     apex_id INTEGER NOT NULL REFERENCES Aapex (id) ON DELETE CASCADE,
     opex_id INTEGER NOT NULL REFERENCES Opex (id) ON DELETE CASCADE,
 supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine(id) ON DELETE CASCADE,
  id serial  PRIMARY KEY, 
  projet_id int,
    forage numeric(12,5),
   frac numeric(12,5),
    manifod numeric(12,5),
    manifod_rassemblement  numeric(12,5),
    compresseur  numeric(12,5),
   mpf numeric(12,5),
    pip numeric(12,5),
    capex_ms numeric(12,5),
    abex_ms numeric(12,5),
    lease_operating_expense numeric(12,5),
  gathening numeric(12,5),
 workover_cost  numeric(12,5),
opes_ms numeric(12,5),
  total_ms numeric(12,5),
      FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE
);



CREATE TABLE total_de_couts_p50 (
  id serial  PRIMARY KEY, 
   supply_chain_id INTEGER NOT NULL REFERENCES supply_chaine (id) ON DELETE CASCADE,
  porjet_id int,
    forage numeric(12,5),
   frac numeric(12,5),
    manifod numeric(12,5),
    manifod_rassemblement  numeric(12,5),
    compresseur  numeric(12,5),
   mpf numeric(12,5),
    pip numeric(12,5),
    capex_ms numeric(12,5),
    abex_ms numeric(12,5),
    lease_operating_expense numeric(12,5),
  gathening numeric(12,5),
 workover_cost  numeric(12,5),
opes_ms numeric(12,5),
  total_ms numeric(12,5),
      FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE
);

CREATE TABLE total_de_couts_p10 (
  id serial  PRIMARY KEY, 
       capex_id INTEGER NOT NULL REFERENCES Capex (id) ON DELETE CASCADE,
     apex_id INTEGER NOT NULL REFERENCES Aapex (id) ON DELETE CASCADE,
     opex_id INTEGER NOT NULL REFERENCES Opex (id) ON DELETE CASCADE,
  projet_id int,
    forage numeric(12,5),
   frac numeric(12,5),
    manifod numeric(12,5),
    manifod_rassemblement  numeric(12,5),
    compresseur  numeric(12,5),
   mpf numeric(12,5),
    pip numeric(12,5),
    capex_ms numeric(12,5),
    abex_ms numeric(12,5),
    lease_operating_expense numeric(12,5),
  gathening numeric(12,5),
 workover_cost  numeric(12,5),
opes_ms numeric(12,5),
  total_ms numeric(12,5),
      FOREIGN KEY (projet_id) REFERENCES Projet(id) ON DELETE CASCADE
);