export const NavBar = () => {
    return (
        <div className="w-full h-16 relative my-4">
            {/* Create a horizontal line for the top of the track */}
            <div className="absolute top-0 w-full h-[4px] bg-black"></div>

            {/* Create a horizontal line for the bottom of the track */}
            <div className="absolute bottom-0 w-full h-[4px] bg-black"></div>

            {/* Create the vertical rungs */}
            <div className="h-full w-full flex mx-4">
                {/* Use flex and gap to space rungs evenly */}
                <div className="flex-1 flex justify-start gap-8">
                    {[...Array(100)].map((_, index) => (
                        <div
                            key={index}
                            className="h-full w-[4px] bg-black"
                        />
                    ))}
                </div>
            </div>
        </div>
    )
}
