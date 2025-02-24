
import { MapContainer, Polyline, TileLayer } from 'react-leaflet';
import { useQuery } from "@tanstack/react-query";

const getRailways = async () => {
    const response = await fetch('http://127.0.0.1:8080/railways');
    return await response.json();
};

type LatLon = {
    lat: number,
    lon: number
}

type Segment = {
    start: LatLon,
    end: LatLon,
    id: number
}

export default function Map() {
    const { data } = useQuery<Segment[]>({
        queryKey: ['railways'], queryFn: getRailways
    });

    const pathOptions = { color: 'red' };

    return (
        <div className='w-full h-full'>
            <MapContainer
                center={[40.767892, -98.929830]}
                zoom={5}
                className="h-[800px]"
            >

                <TileLayer
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                />
                {data?.map((s) => <Polyline pathOptions={pathOptions} positions={[[s.start.lat, s.start.lon], [s.end.lat, s.end.lon]]} />)}
            </MapContainer>
        </div >
    )
}