import csv,argparse,math
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from plot_gdp_regions_2100_cbnal0 import CODES,NAMES
CODES=["World"]+list(CODES); NAMES=["World"]+list(NAMES)
root=Path(__file__).resolve().parents[1];p=argparse.ArgumentParser();p.add_argument('--input',type=Path,default=root/'output/et_npv5_source.csv');p.add_argument('--out',type=Path,default=root/'output');a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
S=['SSP2_2020NDC_NZE_NoCC_No','SSP2_2020_NZE_test_NoCC_No'];d={}
with a.input.open(encoding='utf-8-sig') as f:
 for r in csv.DictReader(f):
  if r['scenario'] in S and r['region'] in CODES and r['year']=='2100' and r['variable']=='Pol_Cos_Cns_Los_rat_NPV_5pc':
   k=(r['scenario'],r['region']);assert k not in d;d[k]=float(r['value'])
assert len(d)==36
rows=[]
for r,n in zip(CODES,NAMES):
 no=d[S[0],r];et=d[S[1],r];assert no<100
 value=100*(et-no)/(100-no);assert math.isfinite(value)
 rows.append([r,n,no,et,value])
stem='cumulative_consumption_loss_ET_relative_to_NZE_5pct_2100'
with (a.out/(stem+'.csv')).open('w',encoding='utf-8-sig',newline='') as f:
 w=csv.writer(f);w.writerow(['region','name','noET_loss_vs_baseline_pct','ET_loss_vs_baseline_pct','ET_loss_relative_to_noET_pct']);w.writerows(rows)
fig,ax=plt.subplots(figsize=(16,9));ax.scatter(range(len(CODES)),[r[4] for r in rows],marker='o',color='#808080',s=100,linewidths=2,label='NZE_w/ET relative to NZE_w/oET')
ax.axhline(0,color='#555',lw=1);ax.set_xticks(range(len(CODES)),NAMES,rotation=90);ax.set_ylabel('Cumulative consumption loss relative to NZE_w/oET (%)');ax.set_xlabel('Region');ax.set_title('Cumulative consumption loss through 2100\nRelative to NZE_w/oET, 5% annual discount rate');ax.grid(axis='y',alpha=.2);ax.set_axisbelow(True);ax.spines[['top','right']].set_visible(False)
fig.text(.08,.018,'Positive: loss from ET; negative: gain from ET. NZE_w/oET = 0%.\nRebased stored loss rates: 100 × (L_ET − L_noET) / (100 − L_noET).',fontsize=11)
fig.tight_layout(rect=(0,.08,1,1))
for ext in ['png','svg','pdf']:fig.savefig(a.out/(stem+'.'+ext),dpi=200,bbox_inches='tight')
(a.out/(stem+'_README.txt')).write_text('Source: global_17_IAMC.gdx; extracted input '+str(a.input.resolve())+'\nIndicator: Pol_Cos_Cns_Los_rat_NPV_5pc at 2100; NZE_test=ET. No further discounting or accumulation.\nRebasing formula: 100*(L_ET-L_noET)/(100-L_noET), rates expressed in percent. This assumes the stored rates use a common baseline denominator for the two scenarios.\nIf L is a consumption-level gap, this equals 100*(C_noET-C_ET)/C_noET for discounted cumulative consumption. If L is equivalent-variation welfare loss, this is a rebased welfare-equivalent consumption index, not verified actual expenditure loss. Upstream definition remains unverified.\nNot a percentage-point difference. No claim of required aid amount.\n',encoding='utf-8')
print(rows)

