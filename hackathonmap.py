#%%
import requests
import pandas as pd
import time

df = pd.read_csv("D:\BuyersedgePlatform\TB_UBIGEOS.csv",delimiter=';', encoding='utf-8',dtype={'ubigeo_inei': str})

resultados = pd.DataFrame()
for index, row in df.iterrows():
    url = "http://sige.inei.gob.pe/test/atlas/index.php/area_influencia/consultar_reporte_zsc"

    headers = {
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "Accept-Language": "en-US,en;q=0.9,es;q=0.8",
        "Connection": "keep-alive",
        "Cookie": "_ga=GA1.3.1302046728.1718988508; _gid=GA1.3.712193160.1718988508; _ga_YNENEGXC8F=GS1.3.1718990870.2.0.1718990870.60.0.0; ci_session=a%3A7%3A%7Bs%3A10%3A%22session_id%22%3Bs%3A32%3A%22b684dd3cf82d13fe0578ba98adc69876%22%3Bs%3A10%3A%22ip_address%22%3Bs%3A13%3A%2238.255.110.91%22%3Bs%3A10%3A%22user_agent%22%3Bs%3A50%3A%22Mozilla%2F5.0+%28Windows+NT+10.0%3B+Win64%3B+x64%29+AppleWeb%22%3Bs%3A13%3A%22last_activity%22%3Bi%3A1718990389%3Bs%3A8%3A%22username%22%3Bs%3A9%3A%22invitado2%22%3Bs%3A9%3A%22logged_in%22%3Bb%3A1%3Bs%3A10%3A%22id_session%22%3Bs%3A3%3A%22228%22%3B%7Dd94f3552be54f337ff424f9b3850e6cd",
        "Referer": "http://sige.inei.gob.pe/test/atlas/",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
        "X-Requested-With": "XMLHttpRequest"
    }

    params = {
        "ubigeo": f"{str(row['ubigeo_inei'])}",
        #"ubigeo": "010101",
        "ccpp": "0001",
        "_search": "false",
        "nd": str(int(time.time() * 1000)),
        "rows": "300",
        "page": "1",
        "sidx": "",
        "sord": "asc"
    }
    response = requests.get(url, headers=headers, params=params, verify=False)
    #print(response)
    # if response.status_code == 200:
    #     data = response.json()
    #     #print(data['rows'])
    #     resultados = pd.concat([resultados, data['rows']], ignore_index=True)
    if response.status_code == 200:
        data = response.json()
        if 'rows' in data:
            rows = pd.json_normalize(data['rows'])
            resultados = pd.concat([resultados, rows], ignore_index=True)
#%%
resultados.head(4)
        
#%%
type(resultados.iloc[0,1])
#%%
columns = {}
for index, row in resultados.iterrows():
    key, value = row['cell'][0],row['cell'][1]
    if key not in columns:
        columns[key] = []
    columns[key].append(value)

# Crear un nuevo dataframe con los datos reestructurados
reshaped_data = pd.DataFrame(columns)

# Mostrar el dataframe resultante
#import ace_tools as tools; tools.display_dataframe_to_user(name="Reshaped Data", dataframe=reshaped_data)
reshaped_data.head()

#%%
reshaped_data.to_excel("info10.xlsx",index=False)
