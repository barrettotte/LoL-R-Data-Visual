from requests.auth import HTTPBasicAuth
import requests, json

def main():
    with open("./config.json", 'r') as privateConfig:
        config = json.load(privateConfig)
        
    print(requests.get(
        "https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/" + config["test-summoner"]["username"], 
        headers={"Accept": "application/json","X-Riot-Token": config["api-key"]}
    ).json())

if __name__ == "__main__": main()