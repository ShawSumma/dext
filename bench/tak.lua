local function tak(x, y, z)
    if y < x then
        return 1 + tak(
            tak(x-1, y, z),
            tak(y-1, z, x),
            tak(z-1, x, y)
        )
    else
        return z
    end
end

print(tak(57, 49, 84))