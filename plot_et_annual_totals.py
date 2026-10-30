"""Annual regional ET welfare gains/losses from extracted IAMC Pol_Cos_Cns_Los."""
import argparse,csv,math
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
p=argparse.ArgumentParser();root=Path(__file__).resolve().parents[1]
p.add_argument('--input',type=Path,default=root/'output/et_effect_annual_regions.csv');p.add_argument('--out',type=Path,default=root/'output');a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
with a.input.open(encoding='utf-8-sig') as f:rows=list(csv.DictReader(f))
years=sorted({int(r['year']) for r in rows});totals=[]
for y in years:
 rr=[r for r in rows if int(r['year'])==y];assert len(rr)==17 and len({r['region'] for r in rr})==17
 vals=[float(r['additional_loss_billion_USD2010_per_year']) for r in rr];assert all(math.isfinite(v) for v in vals)
 loss=sum(max(v,0) for v in vals);gain=sum(max(-v,0) for v in vals)
 assert math.isclose(gain-loss,-sum(vals),abs_tol=1e-8)
 totals.append([y,loss,gain,gain-loss])
stem='et_annual_total_benefits_losses_2020_2100'
with (a.out/(stem+'.csv')).open('w',encoding='utf-8-sig',newline='') as f:
 w=csv.writer(f);w.writerow(['year','total_losses_billion_USD2010_per_year','total_benefits_billion_USD2010_per_year','net_benefit_billion_USD2010_per_year']);w.writerows(totals)
plt.rcParams.update({'font.size':16,'axes.labelsize':19,'axes.titlesize':21})
fig,ax=plt.subplots(figsize=(13,8))
ax.plot(years,[r[2] for r in totals],color='#1565C0',marker='o',lw=2.5,label='Total benefits from ET')
ax.plot(years,[r[1] for r in totals],color='#1565C0',marker='x',ls='--',lw=2.5,label='Total additional losses from ET')
ax.set(xlabel='Year',ylabel='Consumption loss difference\n(billion USD 2010/yr)',title='Annual benefits and losses from emissions trading\nSum across 17 regions relative to NZE_w/oET')
ax.set_xticks(range(2020,2101,10));ax.set_xlim(2019,2101);ax.set_ylim(bottom=0);ax.grid(alpha=.22);ax.legend(frameon=False);ax.spines[['top','right']].set_visible(False)
fig.text(.08,.02,'Source: IAMC Pol_Cos_Cns_Los. Both totals shown as positive magnitudes; no discounting.\nMarkers: stored 5-year observations. Connecting lines are visual guides, not annual model outputs.',fontsize=11)
fig.tight_layout(rect=(0,.08,1,1))
for ext in ['png','svg','pdf']:fig.savefig(a.out/(stem+'.'+ext),dpi=200,bbox_inches='tight')
(a.out/(stem+'_README.txt')).write_text('Input: '+str(a.input.resolve())+'\nOriginal source: C:/AIMHub_fig/data/global_17_IAMC.gdx, IAMC_Template, Pol_Cos_Cns_Los.\nET = SSP2_2020_NZE_test_NoCC_No; noET = SSP2_2020NDC_NZE_NoCC_No.\nFor each region-year, delta = ET consumption loss - noET consumption loss.\nTotal losses = sum(max(delta,0)); total benefits = sum(max(-delta,0)).\nClassification recalculated each year; both plotted as positive magnitudes. No NPV, discounting, or time aggregation. Five-year stored observations only; lines do not claim annual model outputs.\nAll 17 unique regions verified each observation year. Positive differences near numerical zero are retained in CSV.\nThese are consumption-based economic effects, not permit payment receipts, and not guaranteed compensation requirements.\n',encoding='utf-8')
print(totals)
