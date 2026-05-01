# Olist Marketing Funnel Analysis

**Domain:** E-Commerce / Seller Acquisition  
**Data:** Real-world dataset from Olist (Brazil's largest marketplace)  
**Period:** June 2017 – May 2018  
**Tools:** Python (Pandas, Matplotlib) · Power BI

---

## Business Problem

Olist grows revenue by onboarding new sellers onto their marketplace platform. Their sales team was struggling with a low lead-to-conversion rate across multiple marketing channels. This project diagnoses where leads are lost in the funnel and which channels and segments deserve more investment.

---

## Dataset

| File | Rows | Description |
|------|------|-------------|
| `olist_marketing_qualified_leads_dataset.csv` | 8,000 | One row per MQL: contact date, landing page, acquisition channel |
| `olist_closed_deals_dataset.csv` | 842 | Won deals: seller ID, SDR/SR assigned, business segment, won date |

**Key join:** `mql_id` (present in both files)

---

## Funnel Stages

```
MQL (8,000) → SDR Contact (842) → SR Consultancy (842) → Won Deal (842)
                   ↓ −89.5%
              Biggest drop-off
```

**Overall conversion rate: 10.5%**  
The critical leak is between MQL and first SDR contact — 89.5% of leads never receive a sales call.

---

## Key Findings

### 1. Channel Quality vs. Volume
| Channel | Leads | Deals | Conversion Rate |
|---------|-------|-------|----------------|
| Organic Search | 2,296 | 271 | **11.8%** |
| Paid Search | 1,586 | 195 | **12.3%** |
| Social | 1,350 | 75 | 5.6% |
| Email | 493 | 15 | 3.0% |
| Referral | 284 | 24 | 8.5% |

- **Paid Search** and **Organic Search** have nearly identical conversion rates (~12%) but Social and Email trail at 3–6%.
- Social brings the 3rd most leads but converts at half the rate of search channels.

### 2. Funnel Drop-off
- The MQL → SDR transition is where **7,158 leads vanish** (89.5%).
- This suggests SDR capacity is the constraint, not sales quality — the team cannot process the volume.

### 3. Segment Close Speed (Avg Days)
| Segment | Avg Days | Verdict |
|---------|----------|---------|
| Sports & Leisure | 27d | ✅ Fast |
| Health & Beauty | 35d | ✅ Fast |
| Home Decor | 50d | ⚠️ Slow |
| Audio/Video Electronics | 63d | 🔴 Slow |
| Construction Tools | 61d | 🔴 Slow |

- **Health & Beauty** is a sweet spot: 93 deals closed, 35-day average — high volume + fast close.
- **Home Decor** has the most deals (105) but takes 50 days — onboarding friction likely.

---

## Recommendations

1. **Scale SDR capacity or add lead scoring** — 89.5% of leads never get contacted. Even routing the top 20% of leads (by channel quality + segment) to SDRs would double won deals without new marketing spend.

2. **Shift Social budget toward Paid/Organic Search** — Social brings 1,350 leads at 5.6% conversion vs. search at 12%. Reallocating 30% of social budget to search improves lead quality per rupee spent.

3. **Create a fast-track onboarding pack for Home Decor** — It is the highest-volume segment (105 deals) but takes 50 days to close. A pre-built seller starter kit targeting this segment could cut close time by 15–20 days.

4. **Prioritize Health & Beauty for SDR outreach** — Fastest large-volume segment (93 deals, 35-day avg). First-call priority for SDRs should filter for this segment to maximize SDR productivity.

---

## Files

| File | Use |
|------|-----|
| `olist_master_dataset.csv` | Power BI source (merged, 8,000 rows, 20 cols) |
| `olist_funnel_dashboard.png` | 5-chart analysis dashboard |
| `README.md` | This file |

---

## Skills Demonstrated

- Data merging & funnel construction (Python / Pandas)
- Conversion rate analysis across acquisition channels
- Time-based segmentation (days to close)
- Business insight translation into actionable recommendations
- Dashboard design (Matplotlib)
- Power BI-ready data preparation
