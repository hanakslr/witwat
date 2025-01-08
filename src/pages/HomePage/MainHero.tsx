export const MainHero = () => {
    return (
        <div className="flex flex-col md:flex-row relative md:h-[400px] lg:h-[600px]">
            <div className="inline-flex flex-col p-8 md:p-12 lg:p-24">
                <div className="py-6 text-center md:text-left">
                    <div>
                        <h1 className="text-6xl md:5xl lg:text-7xl text-stroke-4-black text-white">What if there</h1>
                    </div>
                    <h1 className="text-6xl md:5xl lg:text-8xl font-bold lg:ml-16">was a train?</h1>
                </div>

                <div className="border-y-2 mx-4 border-black">
                    <div className="border-x-2 mx-8 align-center border-black">
                        <h3 className="text-md p-1 text-center italic uppercase text-green-500 tracking-widest">Envisioning high speed rail in the US</h3>
                    </div>
                </div>
            </div>
            <img
                src="/src/assets/hero_train.svg"
                alt="High speed train illustration"
                className="w-full md:w-1/2 md:absolute md:bottom-0 md:right-0"
            />
        </div>
    )
}