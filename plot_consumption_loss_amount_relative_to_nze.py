"""ET additional cumulative loss relative to NZE: direct stored 5% NPV at 2100."""
import argparse,csv,math
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from plot_gdp_regions_2100_cbnal0 import CODES,NAMES
CODES=["World"]+list(CODES); NAMES=["World"]+list(NAMES)
root=Path(__file__).resolve().parents[1];p=argparse.ArgumentParser();p.add_argument('--input',type=Path,default=root/'output/et_stored_npv_regions_with_world_2100.csv');p.add_argument('--out',type=Path,default=root/'output');a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
with a.input.open(encoding='utf-8-sig') as f:rows=[r for r in csv.DictReader(f) if r['discount_percent']=='5']
assert len(rows)==18 and {r['region'] for r in rows}==set(CODES)
d={r['region']:r for r in rows};values=[];result=[]
for code,name in zip(CODES,NAMES):
 r=d[code];no=float(r['noET_stored_NPV']);et=float(r['ET_stored_NPV']);delta=et-no
 assert math.isfinite(delta) and math.isclose(delta,float(r['ET_minus_noET_stored_NPV']),abs_tol=1e-8)
 values.append(delta/1000);result.append([code,name,no,et,delta,delta/1000])
stem='cumulative_consumption_loss_amount_ET_relative_to_NZE_5pct_2100'
with (a.out/(stem+'.csv')).open('w',encoding='utf-8-sig',newline='') as f:
 w=csv.writer(f);w.writerow(['region','name','NZE_NPV_billion_USD2010','ET_NPV_billion_USD2010','ET_minus_NZE_billion_USD2010','ET_minus_NZE_trillion_USD2010']);w.writerows(result)
fig,ax=plt.subplots(figsize=(16,9));ax.scatter(range(len(CODES)),values,marker='o',color='#808080',s=100,linewidths=2)
ax.axhline(0,color='#555',lw=1);ax.set_xticks(range(len(CODES)),NAMES,rotation=90)
ax.set_ylabel('Additional cumulative consumption loss\n(trillion USD 2010)');ax.set_xlabel('Region');ax.set_title('Cumulative consumption loss through 2100\nRelative to NZE_w/oET, 5% annual discount rate');ax.grid(axis='y',alpha=.2);ax.set_axisbelow(True);ax.spines[['top','right']].set_visible(False)
fig.text(.08,.018,'Positive: additional loss from ET; negative: gain from ET. NZE_w/oET = 0.\nStored Pol_Cos_Cns_Los_NPV_5pc: NZE_w/ET minus NZE_w/oET; no additional discounting.',fontsize=11)
fig.tight_layout(rect=(0,.08,1,1))
for ext in ['png','svg','pdf']:fig.savefig(a.out/(stem+'.'+ext),dpi=200,bbox_inches='tight')
(a.out/(stem+'_README.txt')).write_text('Original data: C:/AIMHub_fig/data/global_17_IAMC.gdx; IAMC_Template; Pol_Cos_Cns_Los_NPV_5pc; 2100.\nExtracted input: '+str(a.input.resolve())+'\nReference SSP2_2020NDC_NZE_NoCC_No; ET SSP2_2020_NZE_test_NoCC_No.\nFormula: stored NPV_ET - stored NPV_NZE. No division by consumption, interpolation, discounting or time summation.\nCSV retains billion units; plot divides by 1000 for trillion USD2010. VUMAP labels source as billion USD_2010/yr; interpreted as cumulative NPV here, upstream unit suffix remains unverified.\nPositive=additional loss; negative=benefit; not required compensation amount.\n',encoding='utf-8')
assert math.isclose(values[0],sum(values[1:]),abs_tol=1e-8)
print('World equals sum of 17 regions:', values[0])

