
import { MapContainer, TileLayer } from 'react-leaflet';

export default function Map() {
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
            </MapContainer>
        </div >
    )
}