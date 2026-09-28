# AWS Cloud Resume 🐱

[🐱 Visitami!🐱](https://d2p8tga5cm2arz.cloudfront.net)

Questo progetto è stato il mio modo di mettere in pratica, in modo concreto, tutte le cose che avevo imparato a livello teorico su AWS, Terraform, serverless e deployment. È un cloud resume challenge, ma per me è stato anche un piccolo laboratorio pratico: un progetto divertente, utile e decisamente appassionante.

In pratica, ho creato un portfolio online hostato su AWS, con una pagina front-end statica e un contatore visitatori serverless che aggiorna un valore in DynamoDB tramite Lambda e API Gateway.

Il bello di questo progetto è che non è solo “un sito bello da vedere”: dietro c’è tutta una parte infrastrutturale, configurazione, sicurezza, backend remoto e gestione degli ambienti, che è stata la parte più interessante.

---

## Architettura finale

La struttura è essenzialmente questa:

- Frontend statico: S3
- CDN: CloudFront
- API: API Gateway
- Logica serverless: Lambda
- Persistenza contatore: DynamoDB
- Gestione infrastruttura: Terraform
- State remoto: S3 + DynamoDB Lock Table
- CI/CD: GitHub Actions (in prospettiva/da completare per automazione futura)

Questa è la logica complessiva:

1. Il browser carica la pagina HTML/CSS/JS da CloudFront
2. CloudFront serve il contenuto da un bucket S3
3. Il frontend chiama l’API Gateway
4. API Gateway invoca una Lambda
5. La Lambda aggiorna il valore del contatore in DynamoDB
6. Il valore ritorna al frontend e viene mostrato nella pagina

---

## Componenti implementati

### 1. Frontend statico

Ho costruito la parte visiva con:

- HTML
- CSS
- JavaScript

Il frontend è abbastanza semplice, ma fa il suo lavoro: mostra il CV, i dettagli personali, le competenze e il contatore di visite.

Il file JS fa una fetch verso l’API, poi aggiorna il numero mostrato in pagina.

### 2. S3 per il sito statico

Il sito viene pubblicato in un bucket S3, che è la soluzione naturale per un sito statico.

In questo caso, il bucket è usato per:

- ospitare gli asset front-end
- servire HTML/CSS/JS
- essere integrato con CloudFront per la distribuzione globale e la cache

### 3. CloudFront

CloudFront è la faccia pubblica del sito.

Perché è comodo?

- HTTPS nativo
- distribuzione globale
- cache più veloce
- separa il pubblico dal bucket S3

In pratica, l’utente non va direttamente al bucket ma passa attraverso CloudFront, che è molto più elegante e professionale.

### 4. API Gateway

Ho collegato il frontend con un endpoint API Gateway, che funge da gateway HTTP verso la Lambda.

Questo è importante perché:

- il frontend non parla direttamente con AWS Lambda
- si mantiene una struttura più pulita
- si gestisce meglio il routing e l’accesso

### 5. Lambda

La Lambda è il cuore della logica del contatore.

Responsabilità:

- ricevere la richiesta dall’API Gateway
- leggere/aggiornare il contatore
- interagire con DynamoDB
- restituire il valore aggiornato

È un classico esempio di architettura serverless: si fa solo ciò che serve, senza dover gestire server e provisioning fisico.

### 6. DynamoDB

Qui viene salvato il numero di visitatori.

È una soluzione perfetta per un contatore semplice perché:

- è serverless
- scalabilissima
- molto leggera da gestire

### 7. Terraform

La parte infrastrutturale è stata scritta con Terraform in modo modulare.

Ho separato le componenti in moduli come:

- S3
- CloudFront
- DynamoDB
- Lambda
- API Gateway

Questo ha reso il progetto più ordinato e più facile da gestire, soprattutto quando si voleva cambiare o estendere la configurazione.

---

## Come sono collegate le parti

Il flusso è abbastanza lineare, ma nel dettaglio c’è una bella catena di collegamenti:

- S3 ospita la pagina e gli asset statici
- CloudFront distribuisce la pagina ai visitatori
- il frontend JS chiama un endpoint API Gateway
- API Gateway richiama la Lambda
- la Lambda legge e aggiorna il contatore in DynamoDB
- il valore torna al frontend e viene visualizzato

Questa è la parte che mi ha fatto davvero capire come funzionano i servizi AWS insieme: non sono “isolati”, ma si incastrano come un sistema coerente.

---

## Bootstrap e gestione degli ambienti

Una delle cose più utili che ho imparato è la differenza tra bootstrap e deploy vero e proprio.

### Bootstrap

Il bootstrap serve a creare le basi necessarie per Terraform:

- bucket S3 per lo state remoto
- tabella DynamoDB per il lock
- configurazioni di sicurezza
- gestione degli ambienti

È la parte che prepara il terreno, senza la quale Terraform non avrebbe un backend affidabile per salvare lo stato.

### Ambiente dev vs prod

Un aspetto molto importante che ho capito è che non si può trattare tutto come se fosse lo stesso ambiente.

Nel progetto ho dovuto gestire diverse configurazioni per:

- region
- bucket name
- backend di Terraform
- variabili di ambiente
- profili AWS diversi

Questa cosa è fondamentale in AWS: un ambiente dev e uno prod non devono avere gli stessi parametri, neanche per il backend. È un dettaglio che, a volte, sembra piccolo, ma è davvero importante

### Perché ho dovuto fare attenzione al profilo AWS

Ho imparato che il comando Terraform usa l’identità AWS attiva nel terminale. Quindi se hai un profilo locale come `cloudresume`, ma usi un altro account o un altro profilo, il backend e le risorse vengono creati nel posto sbagliato.

Questo è un punto che sembra banale, ma in pratica è una delle cose che può far perdere ore se non è gestita correttamente.

---

## Difficoltà incontrate

E non sto parlando di “piccole difficoltà”, ma di quelle davvero utili per imparare.

### 1. Nessun backend iniziale

Il primo problema è stato che Terraform non aveva un backend remoto configurato correttamente. Senza backend, lo stato vive localmente e si perde il controllo più facilmente. Ho dovuto creare tutto il bootstrap per far sì che lo stato fosse salvato in S3 e protetto da lock in DynamoDB.

### 2. Configurazione ambiente sbagliata

Ho dovuto capire che il progetto aveva bisogno di ambienti distinti e validi. In pratica, un deploy con variabili o endpoint sbagliati porta a confusione, bucket duplicati e risorse create nel contesto sbagliato.

### 3. Permessi AWS non adeguati

Questa è stata una delle parti più istruttive. Ho dovuto affrontare le policy IAM e capire che Terraform non è “magico”: se l’utente o il ruolo non ha i permessi giusti, tutto si blocca con errori di accesso e denied.

In pratica, ho imparato che:

- l’infrastruttura non dipende solo dalla sintassi Terraform
- dipende anche da chi sta eseguendo il comando
- i permessi AWS sono parte integrante del progetto

### 4. Problemi con i nomi dei bucket

I bucket S3 devono essere globalmente unici. Ho avuto bisogno di capire bene questo aspetto, perché un nome già usato porta a errori che a prima vista sembrano tecnici ma in realtà sono semplicemente problemi di naming.

### 5. Versioni provider e incompatibilità

Un altro momento utile è stato il problema con le versioni dei provider AWS. Ho avuto un mismatch di configurazione che richiedeva una correzione per allineare il provider alla versione corretta. È un classico caso in cui la teoria è facile, ma la pratica ti fa vedere davvero come il provider influenza la risoluzione delle risorse.

### 6. Necessità di gestire backend e deploy in modo disciplinato

Ho capito che in un progetto serio non si fa “init/apply a caso”. Serve una logica chiara:

- bootstrap manuale iniziale
- backend pronto
- deploy infrastruttura
- poi pubblicazione frontend
- poi eventuale automation con GitHub Actions

È una buona pratica che dà ordine e rende il progetto più robusto.

---

## Cosa ho imparato

Questo progetto mi ha aiutato molto a mettere insieme vari concetti che sapevo in teoria:

- Terraform non è solo “scrivere codice”, ma gestire lo stato e il lifecycle delle risorse
- AWS è molto più semplice se si comprendono bene le relazioni tra servizi
- un progetto serverless ha senso solo se si capisce bene il flusso di dati
- la configurazione dell’ambiente è fondamentale
- i permessi IAM sono il vero “punto di accesso” al successo o al fallimento di un deploy
- il bootstrap è una parte intelligente del sistema, non un passaggio inutile

Se devo essere onesta, è stato proprio questo il bello del progetto: non era solo “fare un sito”, era capire come mettere insieme un sistema completo e funzionante.

---

## Conclusione

Questo piccolo progetto mi ha permesso di mettere in pratica tante cose che avevo studiato in teoria, ma senza la pressione di un “deployment reale” di un sistema complesso: ho potuto sperimentare, rompere qualcosa, correggere, capire il perché delle cose e migliorare man mano.

Ed è stato divertente. Io mi piace molto l’aspetto pratico della tecnologia, e questo progetto mi ha dato proprio quella sensazione: creare qualcosa che funziona davvero, su AWS, con infrastruttura, sicurezza, automazione e un po’ di sana pazienza.

È stato un progetto fatto con curiosità, prova ed errori, e proprio per questo mi ha insegnato molto.

---


## Nota finale

Questo progetto è stato il mio modo di trasformare teoria in esperienza reale.