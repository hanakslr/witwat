import { MainHero } from "./MainHero"
import { BreakpointIndicator } from "../../components/BreakpointIndicator"
import { NavBar } from "./NavBar"

export const HomePage = () => {
    return (
        <div className="bg-white">
            <NavBar />
            <MainHero />
            <BreakpointIndicator />
        </div>
    )
}