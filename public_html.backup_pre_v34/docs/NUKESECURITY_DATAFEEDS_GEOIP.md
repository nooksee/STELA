# NukeSecurity Data Feeds: Geo/IP Importer

This importer modernizes the classic NukeSentinel IP2Country update workflow.

Admin workflow:
1. Upload GeoLite2 Country Locations CSV (e.g. GeoLite2-Country-Locations-en.csv)
2. Import Locations (can be continued in chunks)
3. Upload Blocks IPv4 CSV (GeoLite2-Country-Blocks-IPv4.csv) and import
4. Optionally upload/import Blocks IPv6

Notes:
- Import is chunked to stay shared-hosting friendly.
- Nothing auto-updates from the internet; admin triggers uploads/import.
- All events are logged in NukeSecurity (area=datafeeds).
