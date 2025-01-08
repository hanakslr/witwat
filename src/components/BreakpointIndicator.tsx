export const BreakpointIndicator = () => {
    return (
        <div className="fixed top-0 right-0 z-50 p-2 text-white text-sm font-bold
        bg-red-500 sm:bg-yellow-500 md:bg-green-500 lg:bg-blue-500 xl:bg-purple-500 2xl:bg-pink-500">
            <span className="block sm:hidden">xs</span>
            <span className="hidden sm:block md:hidden">sm</span>
            <span className="hidden md:block lg:hidden">md</span>
            <span className="hidden lg:block xl:hidden">lg</span>
            <span className="hidden xl:block 2xl:hidden">xl</span>
            <span className="hidden 2xl:block">2xl</span>
        </div>
    )
}