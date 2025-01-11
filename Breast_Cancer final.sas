libname BC "/home/u61105801/Breast_Cancer";

proc import datafile="/home/u61105801/Breast_Cancer/df_metabric.xlsx" DBMS=xlsx
out=BC.df_metabric;
run;



proc contents data=bc.df_metabric;
run;
proc means data=bc.df_metabric;
run;
proc univariate data=bc.df_metabric;
run;

/* W zbiorze danych df.metabric znajduje się 2509 pacjentek z rakiem piersi.
Wiek pacjentek wynosi od 21 do 96 lat. Średni wiek rozpoznania to 60,4 lat.
Pacjentki przeszły dwa typy operacji: Masketomie lub operacje oszczędzającą pierś.
W zbiorze danych znajduje się 2506 pacjentów z rakiem piersi i 3 pacjentów z mięsakiem piersi, 
ponieważ mięsaki piersi są bardzo rzadką postacią raka piersi, która obejmuje mniej niż 1% wszystkich przypadków raka piersi. 
Najczęstszym podtypem histologicznym raka piersi jest inwazyjny rak przewodowy (IDC), występujący w 1865 przypadkach. 
IDC jest najczęstszą postacią raka piersi, stanowiącą 80% wszystkich rozpoznań raka piersi. 
Wskaźniki te pokazują, że nasz zestaw danych bardzo dokładnie odzwierciedla rzeczywiste scenariusze.

Inne funkcje w zbiorze danych to profile kliniczne pacjentów. 
Cechy te obejmują komórkowość guza, niezależnie od tego, czy pacjent przyjmował chemioterapię, 
terapię hormonalną, radioterapię, czy nie, ER, PR, status HER2, podtyp histologiczny guza, wielkość, stopień zaawansowania itp. 
Cechy te można wykorzystać jako współzmienne w modelach analizy przeżycia , ale wymagają dodatkowej obróbki wstępnej i czyszczenia.


Column: HER2 Status
Original Negative => Encoded 0
Original Positive => Encoded 1

Column: Tumor Other Histologic Subtype
Original Ductal/NST => Encoded 0
Original Lobular => Encoded 1
Original Medullary => Encoded 2
Original Metaplastic => Encoded 3
Original Mixed => Encoded 4
Original Mucinous => Encoded 5
Original Other => Encoded 6
Original Tubular/ cribriform => Encoded 7

Column: Hormone Therapy
Original No => Encoded 0
Original Yes => Encoded 1

Column: Inferred Menopausal State
Original Post => Encoded 0
Original Pre => Encoded 1

Column: Primary Tumor Laterality
Original Left => Encoded 0
Original Right => Encoded 1

Column: Oncotree Code
Original BRCA => Encoded 0
Original BREAST => Encoded 1
Original IDC => Encoded 2
Original ILC => Encoded 3
Original IMMC => Encoded 4
Original MBC => Encoded 5
Original MDLC => Encoded 6
Original PBS => Encoded 7

Column: PR Status
Original Negative => Encoded 0
Original Positive => Encoded 1

Column: Radio Therapy
Original No => Encoded 0
Original Yes => Encoded 1

Column: Sex
Original Female => Encoded 0

Column: 3-Gene classifier subtype
Original ER+/HER2- High Prolif => Encoded 0
Original ER+/HER2- Low Prolif => Encoded 1
Original ER-/HER2- => Encoded 2
Original HER2+ => Encoded 3
*/

/* Age At Diagnosis Distribution */
proc sgplot data=BC.df_metabric;
    histogram AgeAtDiagnosis;
    density AgeAtDiagnosis / type=kernel;
    xaxis label='Age at Diagnosis';
    yaxis label='Frequency';
    title 'Age at Diagnosis Distribution';
run;

/* Type of Breast Surgery Distribution */
proc sgplot data=BC.df_metabric;
    vbar TypeofBreastSurgery / datalabel;
    xaxis label='Type of Breast Surgery';
    yaxis label='Frequency';
    title 'Type of Breast Surgery Distribution';
run;

/* Cancer Type Distribution */
proc sgplot data=BC.df_metabric;
    vbar CancerType / datalabel;
    xaxis label='Cancer Type';
    yaxis label='Frequency';
    title 'Cancer Type Distribution';
run;

/* Cancer Type Detailed Distribution */
proc sgplot data=BC.df_metabric;
    vbar CancerTypeDetailed / datalabel;
    xaxis label='Cancer Type Detailed';
    yaxis label='Frequency';
    title 'Cancer Type Detailed Distribution';
run;

/* Overall Survival Status Distribution */
proc sgplot data=BC.df_metabric;
    vbar OverallSurvivalStatus / datalabel;
    xaxis label='Overall Survival';
    yaxis label='Frequency';
    title 'Overall Survival Status Distribution';
run;


/* Overall Survival (Months) Distribution */
proc sgplot data=BC.df_metabric;
    histogram OverallSurvivalMonths;
    density OverallSurvivalMonths / type=kernel;
    xaxis label='Overall Survival';
    yaxis label='Frequency';
    title 'Overall Survival (Months) Distribution';
run;



ODS TEXT ="Sprawdzenie czy zbiór zawiera braki danych";



/* Tworzenie nowego zbioru danych z ilością brakujących danych dla zmiennych  */
data missing;
   set bc.df_metabric end = eof;
   N + 1;
   array num[*] _numeric_;
   array char[*] _character_;
   array n_count[3000] _temporary_ (3000*0); * Assuming data set has no more than 3000 OBS;
   array c_count[3000] _temporary_ (3000*0);
   do i = 1 to dim(num);
      if missing(num[i]) then n_count[i] + 1;
   end;
   do i = 1 to dim(char);
      if missing(char[i]) then c_count[i] + 1;
   end;
   if eof then do;
      do i = 1 to dim(num);
         Variable = vname(num[i]);
         NMiss = n_count[i];
         output;
      end;
      do i = 1 to dim(char);
         Variable = vname(char[i]);
         NMiss = c_count[i];
         output;
      end;
   end;
keep Variable N NMiss;
run;


proc sql;
create table missing_data as
select variable,nmiss
from missing;
quit;
/********************************************************************************************************************************************************/


/*Metoda nieparametryczna: Metoda Kaplana-Meiera konstrukcji tablic trwania życia*/

/*generowanie wykresu przeżycia*/
proc lifetest data=bc.df_metabric method=KM conftype=linear plots=(ls,s,lls);
time overallsurvivalmonths*overallsurvivalstatus(0);
run;


/* Kod 3

PLOTS=S(NOCENSOR): Ten wykres przedstawia funkcję przeżycia bez uwzględnienia punktów cenzury. 
Cenzura występuje, gdy nie jesteśmy w stanie obserwować zdarzenia końcowego (np. zgonu) - na przykład, jeśli pacjent opuścił badanie wcześniej. 
Wykres z tą opcją pokazuje po prostu krzywą przeżycia bez uwzględnienia tych momentów.

PLOTS=S(ATRISK): Ten wykres pokazuje liczbę jednostek "zagrożonych", czyli tych, które jeszcze nie doznały zdarzenia końcowego lub nie były cenzurowane, 
w różnych punktach czasowych. To jest przydatne do zrozumienia, ile jednostek przyczynia się do estymacji funkcji przeżycia w danym momencie.

PLOTS=S(CL): Ten wykres pokazuje funkcję przeżycia razem z przedziałami ufności. 
Przedziały ufności są ważne do zrozumienia niepewności związanej z naszymi estymatami.
*/

PROC LIFETEST DATA=bc.df_metabric PLOTS=S(NOCENSOR ATRISK CL);
/* PLOTS=S(CB=EP) lub PLOTS=S(CL CB=EP) */
time overallsurvivalmonths*overallsurvivalstatus(0);
RUN;

/* Kod 4 
oszacowanie przedziałów ufności dla każdej jednostki czasu
*/

PROC LIFETEST DATA=bc.df_metabric OUTSURV=a;
time overallsurvivalmonths*overallsurvivalstatus(0);
PROC PRINT DATA=a;
RUN;

/* Kod 5 
Testy różnic funkcji przeżycia między grupami.

Test log-rank jest używany do sprawdzenia, 
czy istnieje statystycznie znacząca różnica między grupami zdefiniowanymi przez zmienną stratyfikacyjną. 
Jeśli p-wartość testu log-rank jest mniejsza od wybranego poziomu istotności (często 0,05), 
możemy odrzucić hipotezę zerową, że nie ma różnicy w czasie przeżycia między grupami. 

*/;



*Podział na warstwy wg zmiennej Cellularity;
PROC LIFETEST DATA=bc.df_metabric PLOTS=S(TEST);
time overallsurvivalmonths*overallsurvivalstatus(0);
STRATA Cellularity;
RUN;

*Podział na warstwy wg zmiennej InferredMenopausalState;
PROC LIFETEST DATA=bc.df_metabric PLOTS=S(TEST);
time overallsurvivalmonths*overallsurvivalstatus(0);
STRATA InferredMenopausalState;
RUN;


/********************************************************************************************************************************************************/


/*Metoda nieparametryczna: Tradycyjne tablice trwania życia*/


/* Kod 7 
Oszacowanie tradycyjnych tablic trwania życia METHOD=LIFE
przy domyślnych odcinkach czasu.
*/;

PROC LIFETEST DATA=bc.df_metabric METHOD=LIFE;
time overallsurvivalmonths*overallsurvivalstatus(0);
RUN;

/* Kod 8 
Wykres funkcji przeżycia i hazardu PLOTS=(S,H).
*/;

PROC LIFETEST DATA=bc.df_metabric  METHOD=LIFE PLOTS=(S,H);
time overallsurvivalmonths*overallsurvivalstatus(0);
RUN;


/* Kod 11 
Test na istotność korelacji zmiennych dla danych df_metabric data. 
Znak testu wskazuje na kierunek zależności między zmienną a czasem przeżycia. 
Test Forward Stepwise Sequence – kolejność zmiennych.
*/;

PROC LIFETEST DATA=bc.df_metabric;
time overallsurvivalmonths*overallsurvivalstatus(0);
    TEST AgeatDiagnosis TypeofBreastSurgery CancerType  
    CancerTypeDetailed  Cellularity Chemotherapy    Pam50Claudinlowsubtype    Cohort  ERstatusmeasuredbyIHC   ERStatus    
    NeoplasmHistologicGrade HER2statusmeasuredbySNP6    HER2Status  TumorOtherHistologicSubtype 
    HormoneTherapy  InferredMenopausalState PrimaryTumorLaterality  Lymphnodesexaminedpositive  MutationCount   
    Nottinghamprognosticindex   OncotreeCode      PRStatus    RadioTherapy    
    Sex Geneclassifiersubtype  TumorSize   TumorStage;
RUN;

/* Kod 14*/ ;

PROC LIFETEST DATA=bc.df_metabric PLOTS=H (CL);
time overallsurvivalmonths*overallsurvivalstatus(0);
RUN;

/**********************Model Wykładniczy******************/

PROC LIFEREG DATA=bc.df_metabric;
    MODEL overallsurvivalmonths*overallsurvivalstatus(0)=AgeatDiagnosis Chemotherapy ERStatus    
    HER2statusmeasuredbySNP6 HER2Status TumorOtherHistologicSubtype 
    HormoneTherapy Lymphnodesexaminedpositive    
    Nottinghamprognosticindex OncotreeCode PRStatus RadioTherapy    
    Geneclassifiersubtype TumorStage
        / D=EXPONENTIAL;PROBPLOT;
RUN;

PROC LIFEREG DATA=bc.df_metabric;
    MODEL overallsurvivalmonths*overallsurvivalstatus(0)=AgeatDiagnosis Chemotherapy ERStatus    
    HER2statusmeasuredbySNP6 HER2Status TumorOtherHistologicSubtype 
    HormoneTherapy Lymphnodesexaminedpositive    
    Nottinghamprognosticindex OncotreeCode PRStatus RadioTherapy    
    Geneclassifiersubtype TumorStage
        / D=Weibull;PROBPLOT;
RUN;

PROC LIFEREG DATA=bc.df_metabric;
    MODEL overallsurvivalmonths*overallsurvivalstatus(0)=AgeatDiagnosis Chemotherapy ERStatus    
    HER2statusmeasuredbySNP6 HER2Status TumorOtherHistologicSubtype 
    HormoneTherapy Lymphnodesexaminedpositive    
    Nottinghamprognosticindex OncotreeCode PRStatus RadioTherapy    
    Geneclassifiersubtype TumorStage
        / D=Gamma;PROBPLOT;
RUN;

/*******************Model Semiparametryczny************************/
/*
Model proporcjonalnego hazardu Coxa jest zasadniczo modelem regresji powszechnie stosowanym 
w badaniach medycznych do badania związku między czasem przeżycia pacjentów a jedną lub więcej współzmiennymi. 
Wspomniana powyżej metoda estymacji Kaplana-Meiera jest przykładem analizy jednowymiarowej. 
Opisuje przeżycie według jednego badanego czynnika, ale ignoruje wpływ innych (współzmienne pacjenta). 
Metody analizy jednoczynnikowej są przydatne tylko wtedy, gdy współzmienne są kategoryczne 
(np. mężczyźni vs kobiety). Nie działają one łatwo w przypadku ciągłych zmiennych towarzyszących, 
takich jak „wiek w chwili rozpoznania”.

Alternatywną metodą oszacowania Kaplana-Meiera jest model proporcjonalnego hazardu Coxa. 
Działa zarówno dla zmiennych ciągłych, jak i jakościowych. 
Ponadto model proporcjonalnego hazardu Coxa rozszerza metody analizy przeżycia, 
aby jednocześnie ocenić wpływ kilku czynników ryzyka na czas przeżycia.
*/

proc phreg data=bc.df_metabric;
    model overallsurvivalmonths*overallsurvivalstatus(0) = AgeatDiagnosis Chemotherapy ERStatus    
    HER2statusmeasuredbySNP6 HER2Status TumorOtherHistologicSubtype 
    HormoneTherapy Lymphnodesexaminedpositive    
    Nottinghamprognosticindex OncotreeCode PRStatus RadioTherapy    
    Geneclassifiersubtype TumorStage/ ties = efron;
run;

/*Weryfikacja założenia proporcjonalnych hazardów*/

proc phreg data=bc.df_metabric;
    model overallsurvivalmonths*overallsurvivalstatus(0) = AgeatDiagnosis_t ERStatus_t
    HER2statusmeasuredbySNP6_t TumorOtherHistologicSubtype_t Lymphnodesexaminedpositive_t
    Nottinghamprognosticindex_t OncotreeCode_t PRStatus_t
    RadioTherapy_t Geneclassifiersubtype_t TumorStage_t Chemotherapy_t
    AgeatDiagnosis Chemotherapy ERStatus    
    HER2statusmeasuredbySNP6 TumorOtherHistologicSubtype 
    Lymphnodesexaminedpositive    
    Nottinghamprognosticindex OncotreeCode PRStatus RadioTherapy    
    Geneclassifiersubtype TumorStage/ ties = efron;
    AgeatDiagnosis_t = AgeatDiagnosis*overallsurvivalmonths; 
    ERStatus_t = ERStatus*overallsurvivalmonths;
    HER2statusmeasuredbySNP6_t = HER2statusmeasuredbySNP6*overallsurvivalmonths;
    TumorOtherHistologicSubtype_t = TumorOtherHistologicSubtype*overallsurvivalmonths;
    Lymphnodesexaminedpositive_t = Lymphnodesexaminedpositive*overallsurvivalmonths;
    Nottinghamprognosticindex_t = Nottinghamprognosticindex*overallsurvivalmonths;
    OncotreeCode_t = OncotreeCode*overallsurvivalmonths;
    PRStatus_t = PRStatus*overallsurvivalmonths;
    RadioTherapy_t = RadioTherapy*overallsurvivalmonths;
    Geneclassifiersubtype_t = Geneclassifiersubtype*overallsurvivalmonths;
    TumorStage_t = TumorStage*overallsurvivalmonths;
    Chemotherapy_t = Chemotherapy*overallsurvivalmonths; 
run;



/* END */

