"""Regional annual (not cumulative) consumption loss rates, 2020-2100.
Run: python prog/plot_consumption_loss_regional_timeseries.py
"""
import argparse,csv,math,subprocess
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
S=['SSP2_2020NDC_NZE_NoCC_No','SSP2_2020_NZE_test_NoCC_No']
R=['World','JPN','USA','CAN','XE25','XOC','TUR','XER','CIS','CHN','IND','XSE','XSA','BRA','XLM','XME','XNF','XAF']
N=['World','Japan','USA','Canada','EU25','Oceania','Turkey','Rest of Europe','Former Soviet Union','China','India','Southeast Asia','Rest of Asia','Brazil','Rest of South America','Middle East','North Africa','Rest of Africa']
V='Pol_Cos_Cns_Los_rat'
def main():
 root=Path(__file__).resolve().parents[1];p=argparse.ArgumentParser(description=__doc__);p.add_argument('--data',type=Path,default=root/'data/global_17_IAMC.gdx');p.add_argument('--out',type=Path,default=root/'output');p.add_argument('--cache',type=Path);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
 if a.cache:
  with a.cache.open(encoding='utf-8-sig') as f:rows=list(csv.DictReader(f))
 else:
  proc=subprocess.Popen(['C:/GAMS/39/gdxdump.exe',str(a.data),'symb=IAMC_Template','format=csv'],stdout=subprocess.PIPE,text=True,encoding='utf-8-sig');rows=[]
  for r in csv.DictReader(proc.stdout):
   if r['SCENARIO'] in S and r['REMF'] in R and r['VEMF']==V:rows.append(dict(scenario=r['SCENARIO'],region=r['REMF'],variable=r['VEMF'],year=r['YEMF'],value=r['Val']))
  if proc.wait():raise RuntimeError('GDX export failed')
 d={};ys=list(range(2020,2101,5))
 for r in rows:
  if r['scenario'] in S and r['region'] in R and r['variable']==V and int(r['year']) in ys:
   k=(r['scenario'],r['region'],int(r['year']))
   if k in d:raise ValueError('Duplicate '+str(k))
   d[k]=float(r['value'])
 for s in S:
  for r in R:
   for y in ys:
    if (s,r,y) not in d or not math.isfinite(d[s,r,y]):raise ValueError(f'Missing or invalid {s} {r} {y}')
 plt.rcParams.update({'font.family':'DejaVu Sans','font.size':12,'axes.titlesize':13,'axes.labelsize':14,'xtick.labelsize':11,'ytick.labelsize':11,'pdf.fonttype':42})
 fig,axs=plt.subplots(5,4,figsize=(10,13),squeeze=False)
 for i,(r,n) in enumerate(zip(R,N)):
  ax=axs.flat[i]
  for s,label,style in zip(S,['NZE_w/oET','NZE_w/ET'],['-','--']):ax.plot(ys,[d[s,r,y] for y in ys],color='#1565C0',linestyle=style,linewidth=2,label=label)
  ax.set_title(n,pad=6);ax.set_xlim(2020,2100);ax.set_xticks([2020,2060,2100]);ax.tick_params(axis='x',labelrotation=45);ax.axhline(0,color='#888888',lw=.7,zorder=0);ax.grid(axis='y',alpha=.18);ax.margins(y=.12)
 for ax in list(axs.flat)[18:]:ax.set_visible(False)
 handles,labels=axs.flat[0].get_legend_handles_labels();fig.legend(handles,labels,loc='lower center',bbox_to_anchor=(.5,.045),ncol=2,frameon=False,fontsize=14)
 fig.supylabel('Consumption loss relative to Baseline (%)',x=.015,fontsize=16);fig.supxlabel('Year',y=.085,fontsize=15)
 fig.text(.08,.014,'Source: global_17_IAMC.gdx / Pol_Cos_Cns_Los_rat\nAnnual loss rates; no discounting or accumulation. NZE_w/ET = NZE_test.\nVertical scales differ by region; World uses the stored World series.',fontsize=9,color='#555555')
 fig.subplots_adjust(left=.10,right=.985,top=.97,bottom=.16,hspace=.58,wspace=.30)
 stem='consumption_loss_regional_timeseries_2020_2100'
 for ext in ['png','svg','pdf']:fig.savefig(a.out/f'{stem}.{ext}',dpi=200,bbox_inches='tight',pad_inches=.15)
 plt.close(fig)
 with (a.out/f'{stem}.csv').open('w',encoding='utf-8-sig',newline='') as f:
  w=csv.writer(f);w.writerow(['region','region_name','year','NZE_woET_pct','NZE_wET_pct']);w.writerows([r,n,y,d[S[0],r,y],d[S[1],r,y]] for r,n in zip(R,N) for y in ys)
 (a.out/f'{stem}_README.txt').write_text('Source: '+str(a.data.resolve())+'\nSymbol: IAMC_Template; variable: Pol_Cos_Cns_Los_rat. Stored rates plotted directly; no multiplication by 100, discounting, or accumulation.\n2020-2100, 5-year observations connected by straight lines; no extrapolation or missing-value filling.\nWorld and 17 regions; World is read directly, not an unweighted mean of regional rates. Each subplot has its own y scale.\nSolid blue: '+S[0]+'; dashed blue: '+S[1]+'.\nAll 612 values checked for presence, uniqueness, finite values.\n',encoding='utf-8')
 print('Validated',len(d),'values; plots saved to',a.out)
if __name__=='__main__':main()
