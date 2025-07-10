# Complete Quality Suite - JavaScript/TypeScript Export

## Panoramica

Questo sistema di quality checks è stato estratto dal progetto **Nutry** per essere riutilizzato come sistema standalone in qualsiasi progetto TypeScript/JavaScript.

## 🎯 Obiettivo

Creare un sistema completo e riusabile per la qualità del codice che include:

- ✅ **Controlli automatici di qualità** (formatting, linting, security, complexity)
- ✅ **Git hooks automatici** (pre-commit, pre-push, commit-msg)
- ✅ **Workflow CI/CD** per GitHub Actions
- ✅ **Setup automatico** per integrazione rapida
- ✅ **Configurazioni ottimizzate** per progetti JavaScript/TypeScript

## 📁 Struttura del Sistema

```
complete-quality-suite/
├── 📄 README.md                     # Documentazione completa
├── 📄 CHANGELOG.md                  # Cronologia delle modifiche
├── 🚀 setup.js                      # Script di setup automatico
├── 📦 package-template.json         # Template package.json con dipendenze
├── 📋 Makefile-template             # Template Makefile per comandi
├──
├── scripts/                         # Script principali
│   ├── quality-check.js            # Runner principale quality checks
│   ├── maintainability-check.js    # Analisi maintainability
│   ├── duplication-check.js        # Controllo duplicazioni
│   └── setup-hooks.js              # Setup ambiente sviluppo
├──
├── configs/                         # File di configurazione
│   ├── .jscpd.json                 # Configurazione duplicazioni
│   ├── .lintstagedrc.js            # Configurazione lint-staged
│   └── .eslintrc.example.js        # Esempio configurazione ESLint
├──
├── hooks/                           # Template git hooks
│   ├── pre-commit                  # Hook pre-commit
│   ├── pre-push                    # Hook pre-push
│   └── commit-msg                  # Validazione commit message
└──
└── workflows/                       # GitHub Actions workflows
    ├── quality-checks.yml          # Workflow quality checks
    └── pre-merge.yml               # Workflow pre-merge
```

## 🛠️ Strumenti Inclusi

### Analisi della Qualità

- **🎨 Formatting**: Prettier, ESLint import sorting
- **🔍 Linting**: ESLint con regole di sicurezza e complessità
- **🔒 Security**: ESLint Security, npm audit, SonarJS
- **📊 Analysis**: ts-prune (dead code), dependency-cruiser
- **📋 Code Quality**: jscpd (duplicazioni), analisi maintainability

### Automazioni

- **🪝 Git Hooks**: Pre-commit, pre-push con Husky
- **🔄 CI/CD**: GitHub Actions per controlli continui
- **📊 Reporting**: Report HTML e JSON per analisi

## 🚀 Come Usare il Sistema

### 1. Setup Automatico (Raccomandato)

```bash
# 1. Copia la cartella nel tuo progetto
cp -r complete-quality-suite /path/to/your/project/

# 2. Esegui il setup automatico
cd complete-quality-suite
node setup.js

# 3. Installa le dipendenze
cd ..
npm install

# 4. Setup git hooks
npm run setup-hooks

# 5. Esegui il primo controllo
npm run quality
```

### 2. Setup Manuale

1. **Copia i file necessari** nelle rispettive posizioni
2. **Aggiorna package.json** con dipendenze e script dal template
3. **Configura git hooks** copiando i file da `hooks/` a `.husky/`
4. **Aggiungi workflow GitHub** da `workflows/` a `.github/workflows/`

## 📋 Comandi Disponibili

Dopo l'installazione, saranno disponibili questi comandi:

```bash
# Controlli qualità
npm run quality              # Tutti i controlli
npm run quality:fix          # Con auto-fix
npm run quality:fast         # Solo controlli essenziali

# Strumenti individuali
npm run lint                 # ESLint
npm run format              # Prettier
npm run type-check          # TypeScript
npm run security            # Analisi sicurezza
npm run maintainability     # Analisi manutenibilità
npm run duplication         # Controllo duplicazioni

# Comandi Make (se presente Makefile)
make quality                # Tutti i controlli
make quality-fix            # Con auto-fix
make lint                   # Solo linting
```

## ⚙️ Personalizzazione

### Directory Sorgente

Per cambiare la directory analizzata (default: `src/`):

```bash
# Tramite flag
node scripts/quality-check.js all --source-dir="lib/"

# Tramite configurazione package.json
"scripts": {
  "lint": "eslint --ext .ts,.tsx,.js,.jsx lib/"
}
```

### Configurazione ESLint

Usa il template fornito:

```bash
cp configs/.eslintrc.example.js .eslintrc.js
# Modifica secondo le tue esigenze
```

### Soglie di Qualità

Modifica i file di configurazione:

- `.jscpd.json` per duplicazioni
- `.eslintrc.js` per regole di complessità
- Script individuali per altre metriche

## 🔧 Integrazione CI/CD

### GitHub Actions

I workflow vengono automaticamente copiati in `.github/workflows/`:

- **`quality-checks.yml`**: Eseguito su ogni push/PR
- **`pre-merge.yml`**: Controlli completi prima del merge

### Altri CI/CD

I script possono essere integrati in qualsiasi sistema CI/CD:

```bash
# Esempio Jenkins/GitLab CI
npm ci
npm run quality
```

## 📊 Reporting

Il sistema genera report dettagliati in `reports/`:

- **HTML**: Report navigabili per duplicazioni e complessità
- **JSON**: Dati strutturati per integrazioni
- **Console**: Output colorato per sviluppo

## 🎯 Benefici

### Per lo Sviluppo

- **Qualità consistente** del codice
- **Prevenzione bug** tramite analisi statica
- **Feedback immediato** durante lo sviluppo
- **Onboarding facilitato** per nuovi sviluppatori

### Per il Team

- **Standard uniformi** di codifica
- **Revisioni code** più rapide
- **Documentazione automatica** della qualità
- **Riduzione debito tecnico**

### Per il Progetto

- **Manutenibilità aumentata** nel tempo
- **Sicurezza migliorata** del codice
- **Performance ottimizzate** tramite dead code detection
- **Compliance** con best practices

## 🔄 Origine e Adattamenti

### Estratto da Nutry

Il sistema è stato estratto dal progetto Nutry dove includeva:

- Controlli specifici database/Supabase (rimossi)
- Configurazioni Next.js specifiche (generalizzate)
- Test E2E con Playwright (resi opzionali)

### Adattamenti per Riuso

- **Configurabilità** per diversi tipi di progetto
- **Rimozione dipendenze** specifiche di Nutry
- **Generalizzazione** dei controlli ambiente
- **Template flessibili** per diverse stack tecnologiche

## 📈 Evoluzione Futura

### Prossimi Sviluppi

- **Edizioni multi-linguaggio** (Python, Go, Ruby, etc.)
- **Template TypeScript** ottimizzati
- **Integrazione Docker** per controlli containerizzati
- **Plugin VS Code** per feedback inline
- **Dashboard web** per visualizzazione metriche

### Architettura Modulare

Dal 9 luglio 2025, il sistema usa un'architettura modulare:

```
complete-quality-suite/
├── editions/
│   ├── javascript/         # JS/TS tools, configs, hooks, workflows
│   └── [future-languages]/ # Futuri: Python, Go, etc.
├── setup.js                # Setup multi-linguaggio
└── LANGUAGE-INTEGRATION-GUIDE.md # Guida integrazione
```

### Community

- **Contributi** per nuovi controlli qualità
- **Integrazioni** per nuovi linguaggi di programmazione
- **Estensioni** per framework specifici
- **Integrazione** con tool di qualità enterprise

---

## 📞 Supporto

Per problemi o suggerimenti relativi a questo sistema:

1. **Consulta la documentazione** in `README.md`
2. **Verifica le configurazioni** nei file di esempio
3. **Testa i controlli** individualmente per debug
4. **Adatta le soglie** secondo le esigenze del progetto

Il sistema è progettato per essere **flessibile** e **adattabile** a diverse esigenze di progetto mantenendo **alte standard di qualità**.
