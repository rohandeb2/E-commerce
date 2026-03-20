import { createSlice, PayloadAction } from "@reduxjs/toolkit";

// Define a type for the slice state
export type CartItem = {
  _id: number | string;
  title: string;
  price: number;
  amount?: number;
  image: string[];
  unit_of_measure: string;
  shop_category: string;
  selectedSize?: string | undefined;
  selectedColor?: string | undefined;
};

export interface CartState {
  cartItems: CartItem[];
  wishlists: AllProduct[];
  isCartOpen: boolean;
  countValue: number;
  selectedSize: string | undefined;
  selectedColor: string | undefined;
}

// Define the initial state using that type
const getInitialCartItems = () => {
  if (typeof window === "undefined") return [];
  try {
    const stored = window.localStorage.getItem("cartItems");
    return stored ? JSON.parse(stored) : [];
  } catch (error) {
    console.error("Error parsing cart items from localStorage:", error);
    // Clear corrupted data
    window.localStorage.removeItem("cartItems");
    return [];
  }
};

const getInitialWishlists = () => {
  if (typeof window === "undefined") return [];
  try {
    const stored = window.localStorage.getItem("wishlists");
    return stored ? JSON.parse(stored) : [];
  } catch (error) {
    console.error("Error parsing wishlists from localStorage:", error);
    // Clear corrupted data
    window.localStorage.removeItem("wishlists");
    return [];
  }
};

const initialState: CartState = {
  cartItems: getInitialCartItems(),
  isCartOpen: false,
  wishlists: getInitialWishlists(),
  countValue: 1,
  selectedSize: undefined,
  selectedColor: undefined,
};

export const cartSlice = createSlice({
  name: "cart",
  initialState,
  reducers: {
    handleCartOpen: (state) => {
      state.isCartOpen = !state.isCartOpen;
    },
    // add to cart
    addToCart: (state, action: PayloadAction<CartItem>) => {
      const item = state.cartItems.find(
        (item) => item._id === action.payload._id &&
                  item.selectedColor === action.payload.selectedColor &&
                  item.selectedSize === action.payload.selectedSize
      );

      if (item) {
        item.amount = item.amount ? item.amount + (action.payload.amount || 1) : (action.payload.amount || 1);
        try {
          localStorage.setItem("cartItems", JSON.stringify(state.cartItems));
        } catch (error) {
          console.error("Error saving cart items to localStorage:", error);
        }
        return;
      }
      state.cartItems = [...state.cartItems, action.payload];
      try {
        localStorage.setItem("cartItems", JSON.stringify(state.cartItems));
      } catch (error) {
        console.error("Error saving cart items to localStorage:", error);
      }
      state.selectedColor = undefined;
      state.selectedSize = undefined;
    },

    // delete
    removeFromCart: (state, action: PayloadAction<number | string>) => {
      state.cartItems = state.cartItems.filter(
        (item) => item._id !== action.payload
      );
      try {
        localStorage.setItem("cartItems", JSON.stringify(state.cartItems));
      } catch (error) {
        console.error("Error saving cart items to localStorage:", error);
      }
      state.countValue = 1;
      state.selectedColor = undefined;
      state.selectedSize = undefined;
    },

    incrementAmount: (state, action: PayloadAction<number | string>) => {
      const item = state.cartItems.find((item) => item._id === action.payload);
      if (item) {
        item.amount = item.amount ? item.amount + 1 : 1;
        try {
          localStorage.setItem("cartItems", JSON.stringify(state.cartItems));
        } catch (error) {
          console.error("Error saving cart items to localStorage:", error);
        }
        return;
      }
    },

    // decrementamount
    decrementAmount: (state, action: PayloadAction<number | string>) => {
      const item = state.cartItems.find((item) => item._id === action.payload);

      if (item) {
        if (item.amount === 1) {
          state.cartItems = state.cartItems.filter(
            (item) => item._id !== action.payload
          );
          try {
            localStorage.setItem("cartItems", JSON.stringify(state.cartItems));
          } catch (error) {
            console.error("Error saving cart items to localStorage:", error);
          }
          return;
        }
        item.amount = item.amount ? item.amount - 1 : 1;
        try {
          localStorage.setItem("cartItems", JSON.stringify(state.cartItems));
        } catch (error) {
          console.error("Error saving cart items to localStorage:", error);
        }
        return;
      }
    },

    // add to wishlist
    toggleToWishlists: (state, action: PayloadAction<AllProduct>) => {
      const existingItem = state.wishlists.find(
        (item) => item._id === action.payload._id
      );
      if (existingItem) {
        state.wishlists = state.wishlists.filter(
          (wishlist) => wishlist._id !== action.payload._id
        );
        try {
          localStorage.setItem("wishlists", JSON.stringify(state.wishlists));
        } catch (error) {
          console.error("Error saving wishlists to localStorage:", error);
        }
      } else {
        state.wishlists = [...state.wishlists, action.payload];
        try {
          localStorage.setItem("wishlists", JSON.stringify(state.wishlists));
        } catch (error) {
          console.error("Error saving wishlists to localStorage:", error);
        }
      }
    },

    // counter
    handleCountValue: (
      state,
      action: PayloadAction<"increment" | "decrement" | "none">
    ) => {
      if (action.payload === "none") {
        state.countValue = 1;
      } else {
        state.countValue =
          action.payload === "increment"
            ? state.countValue + 1
            : state.countValue - 1;
      }
    },

    // selected color
    handleColorChange: (state, action: PayloadAction<string | undefined>) => {
      state.selectedColor = action.payload;
    },

    // selected Sizes
    handleSizeChange: (state, action: PayloadAction<string | undefined>) => {
      state.selectedSize = action.payload;
    },
  },
});

export const {
  addToCart,
  handleCountValue,
  incrementAmount,
  removeFromCart,
  decrementAmount,
  handleCartOpen,
  toggleToWishlists,
  handleColorChange,
  handleSizeChange,
} = cartSlice.actions;
export default cartSlice.reducer;
