# rbfeeder-container

## Overview
A Docker container that packages the RadarBox (RB24) feeder client for contributing ADS-B aircraft tracking data to the RadarBox network.

## Purpose
Enables easy deployment of the RadarBox feeder in containerized environments:
- Contributes ADS-B data to RadarBox network (radarbox.com)
- Provides containerized alternative to native package installation
- Supports multi-architecture deployments (AMD64, ARM64)
- Simplifies setup on non-Raspberry Pi systems

## Architecture

### Dockerfile Structure
Single-stage Debian-based build:
1. **Base**: `debian:bullseye-slim` (latest supported by RadarBox packages)
2. **Dependencies**: Installs `gnupg2`, `lsb-release`, `dirmngr`
3. **Repository configuration**:
   - Adds RadarBox repository to apt sources: `https://apt.rb24.com/`
   - Adds RadarBox GPG key (key ID: 1D043681) from keyserver
4. **Package installation**: Installs `rbfeeder` package
5. **Runtime**: Executes `/usr/bin/rbfeeder`

### Key Installation Details
- Derived from RadarBox installation script: `https://apt.rb24.com/inst_rbfeeder.sh`
- Uses official RadarBox Debian repository
- GPG key from `keyserver.ubuntu.com` with key ID `1D043681`
- Repository: `https://apt.rb24.com/ bullseye main`

## RadarBox Feeder Details

### What rbfeeder Does
- Connects to dump1090 or other ADS-B data sources
- Uploads aircraft tracking data to RadarBox network
- Participates in MLAT (multilateration) for enhanced tracking
- Provides business/enterprise features via RadarBox

### Configuration
- **Config file**: `/etc/rbfeeder.ini` (must be mounted or configured)
- Configuration typically includes:
  - Sharing key (obtained from radarbox.com)
  - Data source (dump1090 host/port)
  - MLAT settings
  - Network configuration

### Outputs
- **Logs**: Standard output/error
- **Network**: Uploads data to RadarBox servers
- **MLAT**: Participates in multilateration network

### Typical Data Flow
```
dump1090/receiver → BEAST/SBS → rbfeeder → RadarBox network
                                    ↓
                                  MLAT
```

## Docker Build
Built using GitHub Actions workflow that creates multi-architecture images:
- Platforms: `linux/amd64`, `linux/arm64`
- Published to: `ghcr.io/paulcager/rbfeeder-container`
- Triggers: Push to main/master, PRs, manual workflow dispatch

### Build Considerations
- Uses Debian Bullseye for compatibility with RadarBox packages
- Relatively large image size due to Debian base and dependencies
- RadarBox feeder is proprietary software maintained by RadarBox

## Deployment

### Prerequisites
1. RadarBox account and sharing key (signup at radarbox.com)
2. Configuration file with receiver details (`/etc/rbfeeder.ini`)
3. Access to ADS-B data source (dump1090, etc.)

### Typical Usage
```bash
docker run -d \
  -v /path/to/rbfeeder.ini:/etc/rbfeeder.ini:ro \
  ghcr.io/paulcager/rbfeeder-container:latest
```

### Volume Mounts
- `/etc/rbfeeder.ini`: Configuration file (required)

### Network Requirements
- **Outbound**: Connection to RadarBox servers
- **Data source**: Connection to dump1090 or other receiver

## Configuration Notes

### Initial Setup
The RadarBox feeder requires configuration via `/etc/rbfeeder.ini`:
1. Sign up at radarbox.com to get a sharing key
2. Create configuration file with sharing key and data source
3. Configure receiver location coordinates
4. Set MLAT preferences

### Common Configuration Options
Configuration file typically includes:
- `key`: RadarBox sharing key
- `data_source`: Type of data source (e.g., "dump1090")
- `source_host`: Hostname/IP of dump1090
- `source_port`: Port for data connection
- `latitude`/`longitude`: Receiver location
- `altitude`: Receiver altitude in meters
- `mlat`: Enable MLAT participation (yes/no)

Example `/etc/rbfeeder.ini`:
```ini
[client]
network_mode=true
key=YOUR_SHARING_KEY_HERE
sn=RBXXXXXXXXXX

[network]
mode=beast
host=dump1090-proxy
port=30005

[mlat]
autoconfig_enabled=1

[dump1090]
# Not used when network mode is enabled

[location]
lat=XX.XXXX
lon=XX.XXXX
alt=XXX
```

## Integration with Other Services

### Works With
- **dump1090**: Primary ADS-B decoder
- **dump1090-proxy**: For aggregating multiple receivers
- **PiAware**: Can run alongside for FlightAware
- **FR24Feed**: Can run alongside for Flightradar24

### Monitoring
- Logs provide operational information
- RadarBox website provides detailed statistics
- Coverage maps available on RadarBox platform
- Business dashboard for commercial users

## Differences from Other Feeders

### RadarBox vs FlightAware
- **Business focus**: RadarBox offers commercial/enterprise features
- **Data access**: RadarBox has paid tiers for API access
- **Coverage**: Different network coverage areas
- **MLAT**: Both support MLAT but different networks

### RadarBox vs Flightradar24
- **Setup**: Similar configuration approach
- **Privacy**: Both have configurable privacy settings
- **Network**: Independent networks and coverage
- **Features**: RadarBox more business-oriented

## Limitations
- Requires Debian Bullseye (latest supported by RadarBox)
- Configuration file must be created manually
- Larger image size compared to pure Go applications
- Proprietary client (not open source)
- Requires sharing key from RadarBox registration

## Development Notes
- Installation derived from official script: `https://apt.rb24.com/inst_rbfeeder.sh`
- GPG key verification ensures package authenticity
- Simple single-process container (just runs rbfeeder)
- No additional startup scripts needed (unlike PiAware)
- Configuration entirely via mounted config file

## Repository Details
- **Source**: Official RadarBox repository at `https://apt.rb24.com/`
- **Channel**: `bullseye main`
- **Package**: `rbfeeder`
- **Documentation**: Available at radarbox.com

## Troubleshooting
- Check logs with `docker logs <container>`
- Verify config file is mounted correctly
- Ensure dump1090 source is accessible
- Check RadarBox dashboard for feeder status
- Verify sharing key is correct in config file
