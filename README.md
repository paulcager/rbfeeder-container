# RadarBox Feeder Container

Docker container for running RadarBox's rbfeeder to contribute ADS-B aircraft tracking data to the RadarBox network.

## Quick Start

```bash
docker run -d \
  --name rbfeeder \
  -v /path/to/rbfeeder.ini:/etc/rbfeeder.ini:ro \
  ghcr.io/paulcager/rbfeeder-container:latest
```

## What This Does

- Connects to your ADS-B receiver (dump1090)
- Uploads aircraft tracking data to RadarBox
- Participates in MLAT (multilateration) for enhanced tracking
- Provides data to RadarBox's commercial and hobbyist platforms

## Prerequisites

1. **RadarBox Account**: Sign up at https://radarbox.com
2. **Sharing Key**: Get your key from RadarBox after registration
3. **Configuration File**: Create `/etc/rbfeeder.ini` with your settings
4. **ADS-B Receiver**: Running dump1090 or compatible software

## Configuration File

Create `rbfeeder.ini` with your settings:

```ini
[client]
network_mode=true
key=YOUR_SHARING_KEY_HERE
sn=RBXXXXXXXXXX

[network]
mode=beast
host=your-dump1090-host
port=30005

[mlat]
autoconfig_enabled=1

[location]
lat=XX.XXXX
lon=XX.XXXX
alt=XXX
```

Replace:
- `YOUR_SHARING_KEY_HERE` with your RadarBox sharing key
- `RBXXXXXXXXXX` with your station serial number
- `your-dump1090-host` with your dump1090 hostname/IP
- Lat/lon/alt with your receiver's location

## Running the Container

### Basic Usage

```bash
docker run -d \
  --name rbfeeder \
  --restart unless-stopped \
  -v /path/to/rbfeeder.ini:/etc/rbfeeder.ini:ro \
  ghcr.io/paulcager/rbfeeder-container:latest
```

### Docker Compose

```yaml
rbfeeder:
  image: ghcr.io/paulcager/rbfeeder-container:latest
  restart: unless-stopped
  volumes:
    - ./rbfeeder.ini:/etc/rbfeeder.ini:ro
```

## Viewing Logs

```bash
# Follow logs
docker logs -f rbfeeder

# Check for successful connection
docker logs rbfeeder | grep -i "connected"
```

## Verification

1. **Check logs** for successful connection messages
2. **Visit RadarBox** at https://radarbox.com
3. **View your station** in your RadarBox account dashboard
4. **Monitor coverage** on the RadarBox coverage map

## Configuration Options

### Network Mode
```ini
[network]
mode=beast         # Use BEAST protocol (recommended)
# mode=sbs1        # Alternative: SBS-1 format
host=dump1090-host
port=30005
```

### MLAT Configuration
```ini
[mlat]
autoconfig_enabled=1  # Auto-configure MLAT
# privacy=1           # Enable privacy mode
```

### Location
```ini
[location]
lat=51.5074    # Latitude (decimal degrees)
lon=-0.1278    # Longitude (decimal degrees)
alt=100        # Altitude (meters above sea level)
```

## Troubleshooting

### Container exits immediately

Check the logs:
```bash
docker logs rbfeeder
```

Common issues:
- Missing or invalid config file
- Incorrect sharing key
- dump1090 host not accessible

### No data appearing on RadarBox

1. Verify dump1090 is running and accessible:
   ```bash
   nc -zv your-dump1090-host 30005
   ```

2. Check that dump1090 is receiving aircraft:
   ```bash
   # If dump1090 has a web interface
   curl http://your-dump1090-host/dump1090/data/aircraft.json
   ```

3. Verify your sharing key is correct

4. Allow 5-10 minutes for data to appear on RadarBox

### MLAT not working

- Ensure `autoconfig_enabled=1` in config
- Check that location coordinates are accurate
- Verify your receiver is in range of other MLAT participants
- Review RadarBox dashboard for MLAT status

## Getting Your Sharing Key

1. Create account at https://radarbox.com
2. Navigate to account settings
3. Find "Sharing Key" or "API Key" section
4. Copy your key to `rbfeeder.ini`

## Data Protocols Supported

RadarBox feeder supports multiple input formats:
- **BEAST**: Binary format (recommended, most efficient)
- **SBS-1**: Text-based BaseStation format

Configure in `[network]` section with `mode=` parameter.

## Requirements

- **Docker**: Any recent version
- **ADS-B Receiver**: dump1090, readsb, or compatible
- **Network**: Internet connection for uploading to RadarBox
- **Configuration**: Valid `rbfeeder.ini` file

## Technical Details

- **Base Image**: Debian Bullseye
- **RadarBox Version**: Latest from RadarBox repository
- **Ports**: None (outbound only)
- **Data Source**: Configurable in `rbfeeder.ini`

## Running Multiple Feeders

You can run RadarBox alongside other feeders:

```yaml
version: '3'
services:
  rbfeeder:
    image: ghcr.io/paulcager/rbfeeder-container:latest
    volumes:
      - ./rbfeeder.ini:/etc/rbfeeder.ini:ro
    restart: unless-stopped

  piaware:
    image: ghcr.io/paulcager/flightaware-container:latest
    environment:
      RECEIVER_HOST: dump1090-proxy
    restart: unless-stopped

  fr24feed:
    image: ghcr.io/paulcager/fr24feeder-container:latest
    volumes:
      - ./fr24feed.ini:/etc/fr24feed.ini:ro
    restart: unless-stopped
```

## Links

- RadarBox: https://radarbox.com
- Sign Up: https://radarbox.com/register
- RadarBox Documentation: https://radarbox.com/sharing-data
- GitHub Repository: https://github.com/paulcager/rbfeeder-container

## Developer Documentation

For detailed technical documentation, architecture details, and development notes, see [CLAUDE.md](CLAUDE.md).

## License

This container uses RadarBox's proprietary rbfeeder software. The container configuration is provided as-is for community use.
