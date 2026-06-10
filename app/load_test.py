import requests
import concurrent.futures
import time

# יש להחליף בכתובת החיצונית (Ingress / HTTPS) של האפליקציה שלך
TARGET_URL = "https://app.aui-assignment.local/" 
TOTAL_REQUESTS = 10000
CONCURRENT_USERS = 50

def send_request():
    try:
        response = requests.get(TARGET_URL, verify=False)
        return response.status_code
    except requests.exceptions.RequestException:
        return None

def run_load_test():
    print(f"Starting load test on {TARGET_URL}")
    print(f"Sending {TOTAL_REQUESTS} requests with {CONCURRENT_USERS} concurrent users...")
    
    start_time = time.time()
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=CONCURRENT_USERS) as executor:
        # יצירת משימות במקביל
        results = list(executor.map(lambda _: send_request(), range(TOTAL_REQUESTS)))
    
    end_time = time.time()
    
    success_count = results.count(200)
    print(f"\n--- Load Test Results ---")
    print(f"Time taken: {end_time - start_time:.2f} seconds")
    print(f"Successful requests (200 OK): {success_count} / {TOTAL_REQUESTS}")
    print(f"Failed requests: {TOTAL_REQUESTS - success_count}")

if __name__ == "__main__":
    run_load_test()