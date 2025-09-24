import requests
import random
import string

class CustomLibrary:

    def get_random_users(self):
        response = requests.get("https://jsonplaceholder.typicode.com/users", verify=False)
        users = response.json()
        for i in users:
            i["birthday"] = self.get_random_birthday()
            i["password"] = self.generate_password()
            i["stateAbbr"] = str(i["address"]["street"][0]) + str(i["address"]["suite"][0]) + str(i["address"]["city"][0]) + str(i["address"]["city"][0])
        print(users)
        return users

    def get_random_birthday(self):
        return str(random.randint(1, 12)).zfill(2) + str(random.randint(1, 28)).zfill(2) + str(random.randint(1999, 2006))
    
    def generate_password(self, length=8):
        chars = string.ascii_letters + string.digits + "!@#$%"
        return ''.join(random.choice(chars) for i in range(length))
    
    def reformat_birthday(self, birthday: str) -> str:
        if "-" in birthday:
            year, month, day = birthday.split("-")
            return f"{month.zfill(2)}{day.zfill(2)}{year}"
        elif len(birthday) == 8:
            month = birthday[0:2]
            day = birthday[2:4]
            year = birthday[4:]
            return f"{year}-{month}-{day}"
        else:
            raise ValueError(f"Invalid birthday format: {birthday}")
        
    def parse_total_spent(self, total_spent_text: str) -> float:
        if not total_spent_text:
            return 0.0
        try:
            cleaned = total_spent_text.replace("$", "").replace(",", "").strip()
            return float(cleaned)
        except ValueError:
            return 0.0

